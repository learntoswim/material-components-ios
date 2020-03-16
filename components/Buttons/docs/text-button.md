<img src="assets/text.gif" alt="An animation showing a Material Design text button." width="128">

[Text buttons](https://material.io/components/buttons/#text-button) are typically used for less-pronounced actions, including those located in dialogs and cards. In cards, text buttons help maintain an emphasis on card content.

### Text button example

Text buttons are implemented by [MDCButton](https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html). To use a text button use the text button theming method on the MDCButton theming extension. For more information on theming extensions see the [Theming section](#theming). 

<!--<div class="material-code-render" markdown="1">-->
#### Swift
```swift
button.applyTextTheme(withScheme: containerScheme)
```

#### Objective-C

```objc
[self.button applyTextThemeWithScheme:self.containerScheme];
```
<!--</div>-->

### Anatomy and Key properties

A text button has a text label and an optional icon.

![Text button anatomy diagram](docs/assets/text-button-diagram.png)

A. Text label<br>
B. Container (Text buttons do not have containers.)<br>
C. Icon<br>

<details>
<summary>Text button attributes</summary>
<br>

|  | Attribute | Related method(s) | Default value |
| --- | --- | --- | --- |
| **Text label** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623992-titlelabel"><code>titleLabel</code></a> | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624018-settitle"><code>setTitle:forState:</code></a> <a href="https://developer.apple.com/documentation/uikit/uibutton/1624022-title"><code>titleForState:</code></a> | A system value |
| **Icon** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624033-imageview"><code>imageView</code></a> | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623997-setimage"><code>setImage:forState:</code></a> <a href="https://developer.apple.com/documentation/uikit/uibutton/1624026-image"><code>imageForState:</code></a> | <code>nil</code> |




</details>

We recommend using [Material Theming](https://material.io/components/\Buttons/#theming) to apply your customizations across your application. For a full list of component properties, go to the API docs.