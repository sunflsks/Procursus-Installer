//
//  ViewController.swift
//  Odysseyra1n
//
//  Created by 23 Aaron on 11/06/2020.
//  Copyright © 2020 23 Aaron. All rights reserved.
//

import Cocoa
import Security
import LAWrapper

class ViewController: NSViewController {
  
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var goButton: NSButton!
    @IBOutlet weak var statusBox: NSBox!
    @IBOutlet var logView: NSTextView!
    @IBOutlet var statusLabel: NSTextField!
    
    var goTouchBarButton: NSButton!
    var progressTouchBarLabel: NSTextField!
    
    var isBusy = false

    override func viewWillAppear() {
        super.viewWillAppear()
        goButton.isEnabled = true
        
        let arch_str = currentArchitecture()!;
        setStatus("Ready to install Procursus for architecture \(arch_str)\n")
        
        if !(arch_str != "x86_64" || arch_str != "arm64") {
            statusLabel.stringValue = "Unknown architecture."
            goButton.isEnabled = false;
        }
        
        else if FileManager.default.fileExists(atPath: "/opt/procursus") {
            statusLabel.stringValue = "Procursus already installed."
            goButton.isEnabled = false;
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
        
        if let windowController = view.window?.windowController as? WindowController {
            goTouchBarButton = windowController.goTouchBarButton
            progressTouchBarLabel = windowController.progressTouchBarLabel
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setStatus(_ status: String, isLogOutput: Bool = false) {
        let font: NSFont
        if #available(macOS 10.15, *) {
            font = NSFont.monospacedSystemFont(ofSize: 0, weight: .regular)
        } else {
            font = NSFont.userFixedPitchFont(ofSize: 0)!
        }

        let attributedString = NSAttributedString(string: status, attributes: [
            .font: font,
            .foregroundColor: NSColor.white
        ])
        if isLogOutput {
            logView.textStorage?.append(attributedString)
        } else {
            logView.textStorage?.setAttributedString(attributedString)
        }
    }
    
    @IBAction func startButtonClick(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "oneClickMode") {
            doStuff()
            return
        }
        
        let confirmAlert = NSAlert()
        confirmAlert.messageText = "Important"
        confirmAlert.informativeText = """
        DISCLAIMER: Use at your own risk. None of the people associated with this project are liable for any damage caused to your device.
        """
        confirmAlert.addButton(withTitle: "Continue")
        confirmAlert.addButton(withTitle: "Cancel")
        confirmAlert.beginSheetModal(for: view.window!) { (response) in
            if response == .alertFirstButtonReturn {
                self.doStuff()
            }
        }
        
    }
    
    func doStuff() {
        statusLabel.stringValue = "Downloading..."
        let arch = currentArchitecture()!

        self.setStatus("Downloading tarball for \(arch)\n")
        let tempDir = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("tempdirplsdel")!
        let tarballPath = tempDir.appendingPathComponent("tarball.zst")
        
        var procursusURL = ""
        
        if arch == "x86_64" {
            procursusURL = "https://cdn.discordapp.com/attachments/817554561246035998/817554657521434654/bootstrap.tar-2.zst"
        }
        
        else {
            procursusURL = "https://cdn.discordapp.com/attachments/763074782220517467/819588605999317022/bootstrap.tar.zst"
        }
        
        URLSession.shared.downloadTask(with:URL.init(string:procursusURL)!) {
            
            url, response, downloadError in
            
            if downloadError != nil {
                DispatchQueue.main.async {
                    NSAlert(error: downloadError!).beginSheetModal(for: self.view.window!, completionHandler:nil)
                }
                self.stopDoingStuff(isError: true)
                return
            }
            
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "Installing..."
                self.setStatus("Preparing for extraction")
            }
            
            _ = try? FileManager.default.removeItem(atPath: tempDir.path)
            
            do {
                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                DispatchQueue.main.async {
                    NSAlert(error: error).beginSheetModal(for: self.view.window!, completionHandler:nil)
                }
                self.stopDoingStuff(isError: true)
                return
            }
            
            DispatchQueue.main.async {
                self.setStatus("Downloaded tarball! Moving to temporary folder\n")
            }
            
            guard let downloadPath: URL = url else { return }
            
            do {
                _ = try? FileManager.default.removeItem(at: tarballPath)
                try FileManager.default.moveItem(at: downloadPath, to: tarballPath)
            } catch {
                DispatchQueue.main.async {
                    NSAlert(error: error).beginSheetModal(for: self.view.window!, completionHandler:nil)
                }
                self.stopDoingStuff(isError: true)
                return
            }
            
            DispatchQueue.main.async {
                self.setStatus("Extracting Procursus\n")
            }
            
            let archive = LAWArchive(archiveAtPath: tarballPath.path)
            archive?.extractArchive(toDirectory: tempDir.path, with:ExtractionOptions.defaultFlags())
            
            _ = try? FileManager.default.removeItem(at: tarballPath)
            
            DispatchQueue.main.async {
                self.setStatus("Moving Procursus to /opt/procursus\n")
            }
            
            let ret = moveFileToPath(tempDir.path + "/opt/procursus", "/opt/procursus")
            
            DispatchQueue.main.async {
                self.setStatus("Making directory root")
            }
            
            makeDirectoryRootOwned("/opt/procursus")
            
            DispatchQueue.main.async {
                self.setStatus("Cleaning up")
            }
            _ = try? FileManager.default.removeItem(at: tempDir)
            
            DispatchQueue.main.async {
                self.setStatus("All done!\nOutput was: \(ret!)")
                self.statusLabel.stringValue = "Done!"
            }
        }.resume()
    }
    
    func stopDoingStuff(isError: Bool = false) {

    }

}
