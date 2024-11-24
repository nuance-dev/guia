import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers
import AppKit

class BackgroundRemovalManager: ObservableObject {
    @Published var isLoading = false
    @Published var inputImage: NSImage?
    @Published var processedImage: NSImage?
    @Published var uploadState: UploadState = .idle
    
    enum UploadState {
        case idle
        case uploading
        case processing
        case completed
        case error(String)
    }
    
    func handleImageSelection(_ image: NSImage) {
        print("Image received for processing")
        Task { @MainActor in
            self.uploadState = .uploading
            self.inputImage = image
            self.processImage(image)
        }
    }
    
    func clearImages() {
            inputImage = nil
            processedImage = nil
            uploadState = .idle
            isLoading = false
        }
    
    func processImage(_ image: NSImage) {
        print("Starting image processing")
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Failed to create CGImage")
            Task { @MainActor in
                self.uploadState = .error("Failed to process image")
            }
            return
        }
        
        Task { @MainActor in
            self.isLoading = true
            self.uploadState = .processing
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let imageSize = image.size
        
        Task.detached(priority: .userInitiated) {
            print("Processing image on background thread")
            if let maskImage = await self.createMaskImage(from: ciImage),
               let outputImage = self.apply(mask: maskImage, to: ciImage),
               let cgOutput = CIContext().createCGImage(outputImage, from: outputImage.extent) {
                print("Image processing successful")
                await MainActor.run {
                    self.processedImage = NSImage(cgImage: cgOutput, size: imageSize)
                    self.isLoading = false
                    self.uploadState = .completed
                }
            } else {
                print("Image processing failed")
                await MainActor.run {
                    self.isLoading = false
                    self.uploadState = .error("Failed to process image")
                }
            }
        }
    }
    
    private func createMaskImage(from inputImage: CIImage) async -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            let maskPixel = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixel)
        } catch {
            print("Error creating mask: \(error)")
            return nil
        }
    }
    
    private func apply(mask: CIImage, to image: CIImage) -> CIImage? {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage
    }
}

struct ContentView: View {
    @StateObject private var manager = BackgroundRemovalManager()
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            VisualEffectBlur(material: .headerView, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    if let image = manager.processedImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 400, maxHeight: 400)
                            .transition(.opacity)
                            .contextMenu {
                                Button("Copy Image") {
                                    copyImageToPasteboard(image)
                                }
                                Button("Save Image") {
                                    saveProcessedImage()
                                }
                                Button("Clear") {
                                    manager.clearImages()
                                }
                            }
                    } else if let image = manager.inputImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 400, maxHeight: 400)
                            .transition(.opacity)
                    } else {
                        DropZoneView(isDragging: $isDragging, onTap: handleImageSelection)
                            .overlay(
                                Text("⌘V to paste")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.primary.opacity(0.05))
                                    )
                                    .padding(.bottom, 40),
                                alignment: .bottom
                            )
                    }
                    
                    if manager.isLoading {
                        LoaderView()
                    }
                    
                    if case .error(let message) = manager.uploadState {
                        Text(message)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .animation(.easeInOut, value: manager.processedImage != nil)
                
                if manager.processedImage != nil {
                    ButtonGroup(buttons: [
                        (
                            title: "Copy",
                            icon: "doc.on.doc",
                            action: {
                                if let image = manager.processedImage {
                                    copyImageToPasteboard(image)
                                }
                            }
                        ),
                        (
                            title: "Save",
                            icon: "arrow.down.circle",
                            action: saveProcessedImage
                        ),
                        (
                            title: "Clear",
                            icon: "trash",
                            action: manager.clearImages
                        )
                    ])
                    .disabled(manager.isLoading)
                }
            }
            .padding(30)
        }
        .frame(minWidth: 600, minHeight: 700)
        .onDrop(of: [.image, .fileURL], isTargeted: $isDragging) { providers in
            loadFirstProvider(from: providers)
            return true
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                    handlePaste()
                    return nil
                }
                return event
            }
        }
    }
    
    private func handlePaste() {
        let pasteboard = NSPasteboard.general
        if let image = pasteboard.getImageFromPasteboard() {
            manager.handleImageSelection(image)
        }
    }
    
    // Add shortcut keys to the menu bar
    init() {
        let pasteMenuItem = NSMenuItem(
            title: "Paste Image",
            action: #selector(NSApplication.sendAction(_:to:from:)),
            keyEquivalent: "v"
        )
        pasteMenuItem.target = NSApp
        pasteMenuItem.representedObject = handlePaste
        
        if let editMenu = NSApp.mainMenu?.item(withTitle: "Edit")?.submenu {
            editMenu.addItem(NSMenuItem.separator())
            editMenu.addItem(pasteMenuItem)
        }
    }
    
    private func loadFirstProvider(from providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        // Try loading as file URL first
        if provider.canLoadObject(ofClass: URL.self) {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let error = error {
                    print("Error loading URL: \(error)")
                    Task { @MainActor in
                        self.manager.uploadState = .error("Failed to load dropped file")
                    }
                    return
                }
                
                if let url = url {
                    self.loadImage(from: url)
                }
            }
        }
        // Then try loading as image
        else if provider.canLoadObject(ofClass: NSImage.self) {
            _ = provider.loadObject(ofClass: NSImage.self) { image, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    Task { @MainActor in
                        self.manager.uploadState = .error("Failed to load dropped image")
                    }
                    return
                }
                
                if let image = image as? NSImage {
                    Task { @MainActor in
                        self.manager.handleImageSelection(image)
                    }
                }
            }
        }
    }
    
    private func loadImage(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let image = NSImage(contentsOf: url) {
            Task { @MainActor in
                manager.handleImageSelection(image)
            }
        }
    }
    
    private func handleImageSelection() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                print("Image selected from panel: \(url)")
                loadImage(from: url)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        print("Handling drop with \(providers.count) providers")
        
        for provider in providers {
            // First try loading as file URL
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { urlData, error in
                    if let error = error {
                        print("Error loading file URL: \(error)")
                        return
                    }
                    
                    if let urlData = urlData as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        print("Loading image from URL: \(url)")
                        loadImage(from: url)
                    }
                }
            }
            // Then try loading as image data
            else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { imageData, error in
                    if let error = error {
                        print("Error loading image data: \(error)")
                        return
                    }
                    
                    if let imageData = imageData as? Data,
                       let image = NSImage(data: imageData) {
                        print("Loading image from data")
                        Task { @MainActor in
                            manager.handleImageSelection(image)
                        }
                    }
                }
            }
        }
    }
    
    private func copyImageToPasteboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    private func saveProcessedImage() {
        guard let processedImage = manager.processedImage else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Processed Image"
        savePanel.message = "Choose a location to save the processed image"
        savePanel.nameFieldStringValue = "processed_image.png"
        
        let response = savePanel.runModal()
        
        if response == .OK,
           let url = savePanel.url,
           let tiffData = processedImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            do {
                try pngData.write(to: url)
            } catch {
                manager.uploadState = .error("Failed to save image: \(error.localizedDescription)")
            }
        }
    }
}
