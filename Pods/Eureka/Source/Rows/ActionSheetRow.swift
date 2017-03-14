//  ActionSheetRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

open class AlertSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        accessoryType = .none
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

public class _ActionSheetRow<Cell: CellType>: OptionsRow<Cell>, PresenterRowType where Cell: BaseCell {
    
    public var onPresentCallback : ((FormViewController, SelectorAlertController<Cell.Value>)->())?
    lazy public var presentationMode: PresentationMode<SelectorAlertController<Cell.Value>>? = {
        return .presentModally(controllerProvider: ControllerProvider.callback { [weak self] in
            let vc = SelectorAlertController<Cell.Value>(title: self?.selectorTitle, message: nil, preferredStyle: .actionSheet)
            if let popView = vc.popoverPresentationController {
                guard let cell = self?.cell, let tableView = cell.formViewController()?.tableView else { fatalError() }
                popView.sourceView = tableView
                popView.sourceRect = tableView.convert(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, from: cell)
            }
            vc.row = self
            return vc
            },
            onDismiss: { [weak self] in
                $0.dismiss(animated: true)
                self?.cell?.formViewController()?.tableView?.reloadData()
            })
    }()
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.makeController(){
                controller.row = self
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
            }
            else{
                presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
            }
        }
    }
}

/// An options row where the user can select an option from an ActionSheet
public final class ActionSheetRow<T: Equatable>: _ActionSheetRow<AlertSelectorCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
