package ru.ice.controls;

import js.html.Image;

import ru.ice.events.Event;
import ru.ice.data.ElementData;
import ru.ice.events.LayoutEvent;
import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Image extends IceControl
{
	public static inline var FROM_MAX_RECT:String = 'from-max-rect';
	public static inline var FROM_MIN_RECT:String = 'from-min-rect';
	public static inline var FIT_TO_CONTAINER_SIZE:String = 'fit-to-container-size';
	
	private var _isLoaded:Bool = false;
	
	private var _imageElement:Dynamic;
	
	public var id:Int;
	
	private var _proportional:Bool = true;
	public var proportional(get, set):Bool;
	private function get_proportional() : Bool {
		return _proportional;
	}
	private function set_proportional(v:Bool) : Bool {
		if (_proportional != v) {
			_proportional = v;
			resizeImage();
		}
		return get_proportional();
	}
	
	private var _useCache:Bool = true;
	
	private var _stretchType:String = FROM_MAX_RECT;
	public var stretchType(get, set):String;
	private function get_stretchType() : String {
		return _stretchType;
	}
	private function set_stretchType(v:String) : String {
		if (_stretchType != v) {
			_stretchType = v;
			resizeImage();
		}
		return get_stretchType();
	}
	
	private var _alignCenter:Bool = false;
	public var alignCenter(get, set):Bool;
	private function get_alignCenter() : Bool {
		return _alignCenter;
	}
	private function set_alignCenter(v:Bool) : Bool {
		if (_alignCenter != v) {
			_alignCenter = v;
			resizeImage();
		}
		return get_alignCenter();
	}
	
	private var _src:String;
	public var src(get, set):String;
	private function get_src() : String {
		return _src;
	}
	private function set_src(v:String) : String {
		if (_src != v) {
			_src = v;
			_imageElement.src = v + (_useCache ? '' : '?n=' + Date.now().getTime());
		}
		return get_src();
	}
	
	private var _requestedWidth:Float = 0;
	private override function set_width(v:Float) : Float {
		if (_requestedWidth != v) {
			_requestedWidth = v;
			resizeImage();
		}
		return get_width();
	}
	
	private var _requestedHeight:Float = 0;
	private override function set_height(v:Float) : Float {
		if (_requestedHeight != v) {
			_requestedHeight = v;
			resizeImage();
		}
		return get_height();
	}
	
	public override function setSize(width:Float, height:Float) : Void
	{
		if (_requestedWidth != width || _requestedHeight != height) {
			_requestedWidth = width;
			_requestedHeight = height;
			resizeImage();
		}
	}
	
	private var ratio(get, never) : Float;
	private function get_ratio() : Float {
		return originalWidth / originalHeight;
	}
	
    public var originalWidth(get, never):Float;
	private function get_originalWidth() : Float {
		return _imageElement.naturalWidth;
	}
	
    public var originalHeight(get, never):Float;
	private function get_originalHeight() : Float {
		return _imageElement.naturalHeight;
	}
	
	private var _isFirstResizedImg:Bool = false;
	private var _lastOriginalWidth:Float = 0;
	private var _lastOriginalHeight:Float = 0;
	private var _lastRequestedWidth:Float = 0;
	private var _lastRequestedHeight:Float = 0;
	
	public function new(?elementData:ElementData, useCache:Bool = true) 
	{
		_useCache = useCache;
		if (elementData == null) {
			elementData = new ElementData({
				'name':'img',
				'classes':['i-img'],
				'interactive': false
			});
		} else {
			elementData.name = 'img';
			elementData.classes = ['i-img'];
			elementData.interactive = false;
		}
		super(elementData);
		_imageElement = cast _element;
		visible = false;
		_element.onload = __onLoadHandler;
		snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
	}
	
	private override function applyStylesIfNeeded() : Void {
		super.applyStylesIfNeeded();
		needResize = true;
	}
	
	private function __onLoadHandler() : Void {
		visible = true;
		_isLoaded = true;
		this.dispatchEventWith(Event.LOADED, false);
	}
	
	public override function update() : Void
	{
		if (_isLoaded) {
			if (!_isFirstResizedImg) {
				_isFirstResizedImg = true;
				resizeImage();
			}
		}
	}
	
	private function resizeImage() : Void
	{
		if (!_isLoaded)
			return;
		if (originalWidth == 0 && originalHeight == 0)
			return;
		
		_lastRequestedWidth = _requestedWidth;
		_lastRequestedHeight = _requestedHeight;
		_lastOriginalWidth = originalWidth;
		_lastOriginalHeight = originalHeight;
		
		if (_proportional) {
			var ratioX:Float = 0, ratioY:Float = 0, r:Float = 0, w:Float = 0, h:Float = 0;
			if (_stretchType == FROM_MAX_RECT) {
				ratioX = _requestedWidth / _lastOriginalWidth;
				ratioY = _requestedHeight / _lastOriginalHeight;
				if (ratioX > ratioY) {
					removeClass(['i-fit-to-viewport', 'i-fit-to-height', 'i-fit-to-container-size']);
					addClass(['i-fit-to-width']);
				} else {
					removeClass(['i-fit-to-width', 'i-fit-to-viewport', 'i-fit-to-container-size']);
					addClass(['i-fit-to-height']);
				}
			} else if (_stretchType == FROM_MIN_RECT) {
				removeClass(['i-fit-to-width', 'i-fit-to-height', 'i-fit-to-container-size']);
				addClass(['i-fit-to-viewport']);
			} else {
				removeClass(['i-fit-to-width', 'i-fit-to-height', 'i-fit-to-viewport']);
				addClass(['i-fit-to-container-size']);
			}
		} else {
			if (_element.offsetWidth != _requestedWidth)
				_element.style.width = _requestedWidth + 'px';
			if (_element.offsetHeight != _requestedHeight)
				_element.style.height = _requestedHeight + 'px';
		}
		_width = _element.offsetWidth;
		_height = _element.offsetHeight;
		if (_alignCenter) {
			x = (_requestedWidth - _width) * .5;
			y = (_requestedHeight - _height) * .5;
		}
		
		this.dispatchEventWith(Event.RESIZE, true);
	}
	
	public override function dispose() : Void
	{
		_imageElement = null;
		super.dispose();
	}
}