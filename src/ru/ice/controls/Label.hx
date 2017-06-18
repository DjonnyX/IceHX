package ru.ice.controls;

import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Label extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-label-style';
	
	private var _wordwap:Bool = false;
	public var wordwap(get, set) : Bool;
	private function get_wordwap() : Bool {
		return _wordwap;
	}
	private function set_wordwap(v:Bool) : Bool {
		if (_wordwap != v) {
			_wordwap = v;
			setWordWrap(v);
		}
		return get_wordwap();
	}
	
	private function setWordWrap(v:Bool) : Void {
		if (v) {
			removeClass(['i-text-no-word-wrap']);
			addClass(['i-text-word-wrap']);
		} else {
			removeClass(['i-text-word-wrap']);
			addClass(['i-text-no-word-wrap']);
		}
	}
	
	private override function get_width() : Float {
		return _element.getBoundingClientRect().width;
	}
	
	/*private override function set_width(v:Float) : Float {
		if (_element.offsetWidth != v) {
			_width = v;
			_element.style.width = v + 'px';
		}
		return super.get_width();
	}*/
	
	private override function get_height() : Float {
		return _element.getBoundingClientRect().height;
	}
	
	/*private override function set_height(v:Float) : Float {
		if (_element.offsetHeight != v) {
			_height = v;
			_element.style.height = v + 'px';
		}
		return super.get_height();
	}*/
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'lb', 'interactive':false});
		else {
			elementData.name = 'label';
			elementData.interactive = false;
		}
		super(elementData);
		snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
		isClipped = true;
		setWordWrap(false);
		styleName = DEFAULT_STYLE;
	}
	
	private var _text:String;
	public var text(get, set) : String;
	private function get_text() : String {
		return _text;
	}
	private function set_text(v:String) : String {
		if (_text != v) {
			_text = v;
			_element.innerHTML = v;
		}
		return get_text();
	}
}