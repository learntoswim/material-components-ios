<img src="assets/outlined.gif" alt="An animation showing a Material Design outlined button." width="115">

[Outlined buttons](https://material.io/components/buttons/#outlined-button) are medium-emphasis buttons. They contain actions that are important, but aren’t the primary action in an app.

### Outlined button example

To achieve an outlined button use the outlined button theming method on the MDCButton theming extension. To access the theming extension see the [Theming section](#theming). 

<!--<div class="material-code-render" markdown="1">-->
#### Swift
```swift
button.applyOutlinedTheme(withScheme: containerScheme)
```

#### Objective-C

```objc
[self.button applyOutlinedThemeWithScheme:self.containerScheme];
```
<!--</div>-->

### Anatomy and Key properties

An outlined button has a text label, a container, and an optional icon.

![Outlined button anatomy diagram](docs/assets/outlined-button-diagram.png)

A. Text label<br>
B. Container<br>
C. Icon<br>

_**Note** A container in iOS refers to a set of components with an applied Material Theme. A container with respect to anatomy refers to the visible bounds of a component._

<details>
<summary><b>Text label</b> and <b>Icon</b> attributes</summary>
<br>

|  | Attribute | Related method(s) | Default value |
| --- | --- | --- | --- |
| **Text label** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1623992-titlelabel"><code>titleLabel</code></a> |  | |
| **Icon** | <a href="https://developer.apple.com/documentation/uikit/uibutton/1624033-imageview"><code>imageView</code></a> |  | |

</details>

We recommend using [Material Theming](https://material.io/components/\Buttons/#theming) to apply your customizations across your application. For a full list of component properties, go to the API docs:"
List the links to each API