//
//  PreferencesViewController.swift
//  Slatus
//
//  Created by Dan Holm on 4/9/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    let delegate = NSApp.delegate as? AppDelegate

    var selectedWorkspace: SlackWorkspace? = nil

    @IBOutlet weak var preferencesOutlineView: NSOutlineView!
    @IBOutlet weak var selectedWorkspaceLabel: NSTextField!
    @IBOutlet weak var newToken: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWorkspaces), name: Notification.Name("conversationListUpdate"), object: nil)

        preferencesOutlineView.delegate = self
        preferencesOutlineView.dataSource = self
    }

    @IBAction func onAddWorkspace(_ sender: Any) {
        let token = self.newToken.stringValue

        self.newToken.stringValue = ""

        self.delegate?.addSlackWorkspace(token, save: true)
    }

    @IBAction func onDeleteWorkspace(_ sender: Any) {
        if let workspace = self.selectedWorkspace {
            self.delegate?.deleteSlackWorkspace(workspace)
        }

        self.selectedWorkspace = nil
        self.selectedWorkspaceLabel.stringValue = "Select a workspace ..."
    }

    @objc func reloadWorkspaces() {
        preferencesOutlineView.reloadData()
    }
}

extension PreferencesViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            if let count = self.delegate?.workspaces.count {
                return count
            }
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            if let workspace = self.delegate?.workspaces[index] {
                return workspace
            }
        }

        return SlackWorkspace()
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
}

extension PreferencesViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        var cell: NSUserInterfaceItemIdentifier?
        var text: String?

        if let workspace = item as? SlackWorkspace {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("TokenColumn") {
                cell = NSUserInterfaceItemIdentifier("TokenCell")
                text = workspace.name
            }
        }

        guard
            let viewCell = cell,
            let viewText = text
        else {
            return view
        }

        view = preferencesOutlineView.makeView(withIdentifier: viewCell, owner: nil) as? NSTableCellView

        if let textField = view?.textField {
            textField.stringValue = viewText
        }

        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let outlineView = notification.object as? NSOutlineView {
            if let workspace = outlineView.item(atRow: outlineView.selectedRow) as? SlackWorkspace {
                let name = workspace.name

                self.selectedWorkspaceLabel.stringValue = name
                self.selectedWorkspace = workspace
            }
        }
    }
}
