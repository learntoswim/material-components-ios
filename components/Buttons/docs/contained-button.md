<img src="assets/contained.gif" alt="An animation showing a Material Design contained button." width="128">

[Contained buttons](https://material.io/components/buttons/#contained-button) are high-emphasis, distinguished by their use of elevation and fill. They contain actions that are primary to your app.

### Contained button example

Contained buttons are implemented by [MDCButton](https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html). To achieve a contained button use the contained button theming method on the MDCButton theming extension. To access the theming extension see the [Theming section](#theming). 

<!--<div class="material-code-render" markdown="1">-->
#### Swift
```swift
button.applyContainedTheme(withScheme: containerScheme)
```

#### Objective-C

```objc
[self.button applyContainedThemeWithScheme:self.containerScheme];
```
<!--</div>-->

### Anatomy and Key properties

A contained button has a text label, a container, and an optional icon.

![Contained button anatomy diagram](docs/assets/contained-button-diagram.png)

A. Text label<br>
B. Container<br>
C. Icon<br>

<details>
<summary>Contained button attributes</summary>
<br>

|  | Attribute | Related method(s) | Default value |
| --- | --- | --- | --- |
| **Text label** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623992-titlelabel"><code>titleLabel</code></a> | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624018-settitle"><code>setTitle:forState:</code></a> <a href="https://developer.apple.com/documentation/uikit/uibutton/1624022-title"><code>titleForState:</code></a> | A system value |
| **Container** |  | <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)setBorderColor:forState:"><code>setBorderColor:forState:</code></a> <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)borderColorForState:"><code>borderColorForState:</code></a> | On surface color at 12% opacity |
| |  | <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)setBorderWidth:forState:"><code>setBorderWidth:forState:</code></a> <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)borderWidthForState:"><code>borderWidthForState:</code></a> | 1 |
| |  | <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)setBackgroundColor:forState:"><code>setBackgroundColor:forState:</code></a> <a href="https://material.io/develop/ios/components/buttons/api-docs/Classes/MDCButton.html#/c:objc(cs)MDCButton(im)backgroundColorForState:"><code>backgroundColorForState:</code></a> | color |
| **Icon** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624033-imageview"><code>imageView</code></a> | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623997-setimage"><code>setImage:forState:</code></a> <a href="https://developer.apple.com/documentation/uikit/uibutton/1624026-image"><code>imageForState:</code></a> | <code>nil</code> |



</details>

We recommend using [Material Theming](https://material.io/components/\Buttons/#theming) to apply your customizations across your application. For a full list of component properties, go to the API docs:"
List the links to each API
