import enthral.Component;
import js.html.Element;

@:expose
class MyComponent implements StaticComponent<{name:String}> {
	public var authorData:{name:String};
	public var meta:ComponentMeta;

	public function new(authorData) {
		this.authorData = authorData;
	}

	public function setupView(container:Element) {
		container.innerHTML = 'Hello ${authorData.name}';
	}
}
