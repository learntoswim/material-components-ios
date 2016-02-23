/*
Copyright 2015-present Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

    let classList = classesRespondingToSelector("catalogHierarchy")

    // Build the catalog tree.

    let tree = Node(title: "Root")
    for c in classList {
      let hierarchy = CatalogHierarchyFromClass(c)

      // Walk and build the tree
      var node = tree
      for name in hierarchy {
        if let child = node.map[name] {
          node = child // Walk the node
          continue
        }
        // Create the node
        let child = Node(title: name)
        node.map[name] = child
        node.children.append(child)
        node = child // Walk the node
      }
      node.viewController = c
    }

    let rootNodeViewController = NodeViewController(node: tree)
    self.window?.rootViewController = UINavigationController(rootViewController: rootNodeViewController)
    self.window?.makeKeyAndVisible()
    return true
  }
}
