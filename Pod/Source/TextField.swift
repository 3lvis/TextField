import UIKit
import InputValidator
import Formatter

public enum TextFieldInputType {
    case Default, Name, Username, PhoneNumber, Integer, Decimal, Address, Email, Password, Unknown
}

public protocol TextFieldDelegate: class {
    func didBeginEditing(textField: TextField)
    func didEndEditing(textField: TextField)
    func didUpdateWithText(text: String?, textField: TextField)
    func didReturn(textField: TextField)
}

public class TextField: UITextField, UITextFieldDelegate {
    dynamic public var customFont: UIFont = UIFont.systemFontOfSize(16) {
        didSet {
            self.font = font
        }
    }
    dynamic public var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    dynamic public var borderColor: UIColor = UIColor.redColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    dynamic public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    dynamic public var activeBackgroundColor: UIColor = UIColor.redColor()
    dynamic public var activeBorderColor: UIColor = UIColor.redColor()
    dynamic public var inactiveBackgroundColor: UIColor = UIColor.redColor()
    dynamic public var inactiveBorderColor: UIColor = UIColor.redColor()

    dynamic public var enabledBackgroundColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }
    dynamic public var enabledBorderColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }
    dynamic public var enabledTextColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }
    dynamic public var disabledBackgroundColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }
    dynamic public var disabledBorderColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }
    dynamic public var disabledTextColor: UIColor = UIColor.redColor() {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }

    dynamic public var validBackgroundColor: UIColor = UIColor.redColor()
    dynamic public var validBorderColor: UIColor = UIColor.redColor()
    dynamic public var invalidBackgroundColor: UIColor = UIColor.redColor()
    dynamic public var invalidBorderColor: UIColor = UIColor.redColor()
    dynamic public var accessoryButtonColor: UIColor = UIColor.redColor()

    public var inputValidator: Validatable?
    public var formatter: Formattable?
    public weak var textFieldDelegate: TextFieldDelegate?

    static let LeftMargin = 10.0
    static let AccessoryButtonWidth = 30.0
    static let AccessoryButtonHeight = 20.0

    override init(frame: CGRect) {
        self.inputType = .Default

        super.init(frame: frame)

        self.delegate = self

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: TextField.LeftMargin, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .Always

        self.addTarget(self, action: "textFieldDidUpdate:", forControlEvents: .EditingChanged)
        self.addTarget(self, action: "textFieldDidReturn:", forControlEvents: .EditingDidEndOnExit)

        self.returnKeyType = .Done
        self.rightViewMode = .WhileEditing
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var customClearButton: UIButton = {
        let image = TextFieldClearButton.imageForSize(CGSize(width: 18, height: 18), color: self.accessoryButtonColor)
        let button = UIButton(type: .Custom)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "clearButtonAction", forControlEvents: .TouchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: TextField.AccessoryButtonWidth, height: TextField.AccessoryButtonHeight)

        return button
    }()

    override public var text: String? {
        didSet {
            if self.formatter != nil {
                self.text = self.formatter!.formatString(text ?? "", reverse: false)
            }
        }
    }

    override public var enabled: Bool {
        didSet {
            self.updateEnabled(self.enabled)
        }
    }

    public var valid: Bool = true {
        didSet {
            if self.enabled {
                self.updateValid(self.valid)
            }
        }
    }

    public var inputType: TextFieldInputType {
        didSet {
            self.updateInputType(inputType)
        }
    }

    // MARK: Public 

    func updateActive(active: Bool) {
        self.rightView = self.customClearButton

        if active {
            self.backgroundColor = self.activeBackgroundColor
            self.layer.backgroundColor = self.activeBackgroundColor.CGColor
            self.layer.borderColor = self.activeBorderColor.CGColor
        } else {
            self.backgroundColor = self.inactiveBackgroundColor
            self.layer.backgroundColor = self.inactiveBackgroundColor.CGColor
            self.layer.borderColor = self.inactiveBorderColor.CGColor
        }
    }

    func updateEnabled(enabled: Bool) {
        if enabled {
            self.backgroundColor = self.enabledBackgroundColor
            self.layer.borderColor = self.enabledBorderColor.CGColor
            self.layer.backgroundColor = self.enabledBackgroundColor.CGColor
            self.textColor = self.enabledTextColor
        } else {
            self.backgroundColor = self.disabledBackgroundColor
            self.layer.borderColor = self.disabledBorderColor.CGColor
            self.layer.backgroundColor = self.disabledBackgroundColor.CGColor
            self.textColor = self.disabledTextColor
        }
    }

    func updateValid(valid: Bool) {
        if valid {
            self.backgroundColor = self.validBackgroundColor
            self.layer.backgroundColor = self.validBackgroundColor.CGColor
            self.layer.borderColor = self.validBorderColor.CGColor
        } else {
            self.backgroundColor = self.invalidBackgroundColor
            self.layer.backgroundColor = self.invalidBackgroundColor.CGColor
            self.layer.borderColor = self.invalidBorderColor.CGColor
        }
    }

    public func validate() -> Bool {
        var isValid = true
        if let inputValidator = self.inputValidator{
            isValid = inputValidator.validateString(self.text ?? "")
        }

        return isValid
    }

    // MARK: UITextFieldDelegate

    public func textFieldDidBeginEditing(textField: UITextField) {
        self.updateActive(true)
    }

    public func textFieldDidEndEditing(textField: UITextField) {
        self.updateActive(false)
    }

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            return true
        }

        if self.inputValidator != nil {
            return self.inputValidator!.validateReplacementString(string, usingFullString: self.text, inRange: range)
        }

        return true
    }

    // MARK: Notification

    func textFieldDidUpdate(textField: TextField) {
        if self.valid == false {
            self.updateValid(true)
        }

        self.textFieldDelegate?.didUpdateWithText(self.text, textField: self)
    }

    func textFieldDidReturn(textField: TextField) {
        self.textFieldDelegate?.didReturn(self)
    }

    // MARK: Actions

    func clearButtonAction() {
        self.text = nil

        self.textFieldDelegate?.didUpdateWithText(self.text, textField: self)
    }
}
