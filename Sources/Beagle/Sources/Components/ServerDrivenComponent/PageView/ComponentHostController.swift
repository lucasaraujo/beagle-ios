/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class ComponentHostController: BeagleController {

    let component: ServerDrivenComponent
    let renderer: BeagleRenderer
    
    var config: BeagleConfiguration

    let bindings = Bindings()

    var serverDrivenState: ServerDrivenState {
        get { renderer.controller?.serverDrivenState ?? .finished }
        set { renderer.controller?.serverDrivenState = newValue }
    }
    var screenType: ScreenType {
        return renderer.controller?.screenType ?? .declarativeText("")
    }
    var screen: Screen? {
        return renderer.controller?.screen
    }

    func addOnInit(_ onInit: [Action], in view: UIView) {
        renderer.controller?.addOnInit(onInit, in: view)
    }
    
    func execute(actions: [Action]?, event: String?, origin: UIView) {
        renderer.controller?.execute(actions: actions, event: event, origin: origin)
    }

    func execute(actions: [Action]?, with contextId: String, and contextValue: DynamicObject, origin: UIView) {
        renderer.controller?.execute(actions: actions, with: contextId, and: contextValue, origin: origin)
    }
    
    public func addBinding<T: Decodable>(expression: ContextExpression, in view: UIView, update: @escaping (T?) -> Void) {
        bindings.add(self, expression, view, update)
    }

    init(_ component: ServerDrivenComponent, renderer: BeagleRenderer) {
        self.component = component
        self.renderer = renderer
        self.config = renderer.controller?.config ?? GlobalConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let beagleRenderer = BeagleRenderer(controller: self)
        view = beagleRenderer.render(component)
    }

    override func viewDidLayoutSubviews() {
        bindings.config()
        BeagleEnvironment.style(view).applyLayout()
        super.viewDidLayoutSubviews()
    }

}
