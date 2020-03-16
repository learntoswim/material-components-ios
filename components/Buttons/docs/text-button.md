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

![Text button anatomy diagram](docs/assets/text-button-anatomy.png)

A. Text label<br>
B. Container (Text buttons do not have containers.)<br>
C. Icon<br>

_**Note** A container in iOS refers to a set of components with an applied Material Theme. A container with respect to anatomy refers to the visible bounds of a component._

<details>
<summary><b>Text label</b> and <b>Icon</b> attributes</summary>
<br>

|  | Attribute | Related method(s) | Default value |
| --- | --- | --- | --- |
| **Text label** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623992-titlelabel"><code>titleLabel</code></a> |  | |
| |  | <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(py)uppercaseTitle"><code>uppercaseTitle</code></a> | YES |
| |  | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623993-settitlecolor"><code>setTitleColor:forState:</code></a> | System default |
| |  | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624018-settitle"><code>setTitle:forState:</code></a> | Black |
| **Color** |  |  | |
| **Typography** |  |  |  |
| **Icon** | | | |
| **Size** | | | |
| **Gravity** (position relative to text label) | | | |
| **Padding** (space between icon and text label) | | | |


</details>

<details>
<summary><b>Container</b> attributes</summary>
<br>

|  | Attribute | Related method(s) | Default value |
| --- | --- | --- | --- |
| **Color** |  |  | |
| **Stroke color** | |  | |
| **Stroke width** |  |  |  |
| **Shape** |  | | |
| **Elevation** | | | |
| **Ripple color** | | | | 
</details>
