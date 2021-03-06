package com.flicker.controls;

import haxe.Constraints.Function;
import com.flicker.controls.super.BaseListItemControl;

import com.flicker.animation.IAnimatable;
import com.flicker.animation.Transitions;
import com.flicker.animation.Tween;
import com.flicker.core.Flicker;
import com.flicker.events.Event;
import com.flicker.layout.HorizontalLayout;
import com.flicker.controls.Button;
import com.flicker.controls.ButtonsGroup;
import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FilterGroup extends FlickerControl
{
	public static inline var DEFAULT_STYLE:String = 'default-filter-group-style';
	
	private var _layoutTween:IAnimatable;
	private var _layoutTween2:IAnimatable;
	
	private var _rightOffset:Float = 0;
	public var rightOffset(get, set) : Float;
	private function set_rightOffset(v:Float) : Float {
		if (_rightOffset != v) {
			_rightOffset = v;
			removeLayoutAnimation();
			_layoutTween = Flicker.animator.tween(layout, .125, {paddingRight:v, transition:Transitions.EASE_OUT, onUpdate:updateTween});
		}
		return get_rightOffset();
	}
	
	private function get_rightOffset() : Float {
		return _rightOffset;
	}
	
	private var _leftOffset:Float = 0;
	public var leftOffset(get, set) : Float;
	private function set_leftOffset(v:Float) : Float {
		if (_leftOffset != v) {
			_leftOffset = v;
			removeLayoutAnimation1();
			_layoutTween2 = Flicker.animator.tween(layout, .30, {paddingLeft:v, transition:Transitions.EASE_OUT, onUpdate:updateTween});
		}
		return get_leftOffset();
	}
	
	private function updateTween() : Void {
		update();
	}
	
	private function get_leftOffset() : Float {
		return _rightOffset;
	}
	
	private var _openButton:Button;
	private var _buttonsGroup:ButtonsGroup;
	private var _container:FlickerControl;
	
	private var _buttonsGroupStyleFactory:Function;
	public var buttonsGroupStyleFactory(get, set) : Function;
	private function set_buttonsGroupStyleFactory(v:Function) : Function {
		if (_buttonsGroupStyleFactory != v) {
			_buttonsGroupStyleFactory = v;
			if (_buttonsGroup != null)
				_buttonsGroup.styleFactory = v;
		}
		return get_buttonsGroupStyleFactory();
	}
	private function get_buttonsGroupStyleFactory() : Function {
		return _buttonsGroupStyleFactory;
	}
	
	private var _openButtonStyleFactory:Function;
	public var openButtonStyleFactory(get, set) : Function;
	private function set_openButtonStyleFactory(v:Function) : Function {
		if (_openButtonStyleFactory != v) {
			_openButtonStyleFactory = v;
			if (_openButton != null)
				_openButton.styleFactory = v;
		}
		return get_openButtonStyleFactory();
	}
	private function get_openButtonStyleFactory() : Function {
		return _openButtonStyleFactory;
	}
	
	private var _containerStyleFactory:Function;
	public var containerStyleFactory(get, set) : Function;
	private function set_containerStyleFactory(v:Function) : Function {
		if (_containerStyleFactory != v) {
			_containerStyleFactory = v;
			if (_container != null)
				_container.styleFactory = v;
		}
		return get_containerStyleFactory();
	}
	private function get_containerStyleFactory() : Function {
		return _containerStyleFactory;
	}
	
	private var _accessoryItems:Array<Dynamic>;
	public var accessoryItems(get, set):Array<Dynamic>;
	private function set_accessoryItems(v:Array<Dynamic>) : Array<Dynamic> {
		if (_accessoryItems != v) {
			_accessoryItems = v;
			if (_buttonsGroup != null)
				_buttonsGroup.accessoryItems = v;
		}
		return get_accessoryItems();
	}
	private function get_accessoryItems() : Array<Dynamic> {
		return _accessoryItems;
	}
	
	private var _tbTween:IAnimatable;
	
	private var _collapsed:Bool = false;
	public var collapsed(get, set) : Bool;
	private function set_collapsed(v:Bool) : Bool {
		if (_collapsed != v) {
			_collapsed = v;
			if (_buttonsGroup != null)
				resetAnimation();
		}
		return get_collapsed();
	}
	private function get_collapsed() : Bool {
		return _collapsed;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'filter', 'interactive':false});
		super(elementData);
		styleName = DEFAULT_STYLE;
	}
	
	override public function initialize() : Void 
	{
		_container = new FlickerControl(new ElementData({'name':'f-container','interactive':false}));
		_container.styleFactory = _containerStyleFactory;
		addChild(_container);
		_buttonsGroup = new ButtonsGroup(new ElementData({'interactive':false}));
		_buttonsGroup.addEventListener(Event.CHANGE, buttonsGroupTriggeredHandler);
		_buttonsGroup.addEventListener(Event.RESIZE, buttonsGroupResizeHandler);
		_buttonsGroup.styleFactory = _buttonsGroupStyleFactory;
		if (_accessoryItems != null)
			_buttonsGroup.accessoryItems = _accessoryItems;
		_container.addChild(_buttonsGroup);
		
		_openButton = new Button();
		_openButton.isToggle = true;
		_openButton.addEventListener(Event.TRIGGERED, triggeredHandler);
		_openButton.styleFactory = _openButtonStyleFactory;
		_openButton.emitResizeEvents = false;
		addChild(_openButton);
		super.initialize();
		
		// start pos
		_buttonsGroup.visible = _collapsed;
		
		Flicker.animator.delayCall(buttonsGroupResizeHandler, .5);
	}
	
	private function buttonsGroupTriggeredHandler(e:Event, data:Dynamic) : Void {
		e.stopImmediatePropagation();
		var items:Array<Dynamic> = cast data;
		var tags:Array<String> = [];
		for (item in items) {
			tags.push(item.tag);
		}
		dispatchEventWith(Event.CHANGE, true, tags);
	}
	
	private function buttonsGroupResizeHandler() : Void {
		if (_buttonsGroup == null) return;
		if (_tbTween != null)
			resetAnimation();
		else
			_buttonsGroup.x = _collapsed ? _container._width - _buttonsGroup._width : _container._width;
	}
	
	private function resetAnimation() : Void {
		removeAnimation();
		_tbTween = Flicker.animator.tween(_buttonsGroup, .35, {x:_collapsed ? _container._width - _buttonsGroup._width : _container._width, transition:Transitions.EASE_OUT, onComplete:animationComplete});
	}
	
	private function animationComplete() : Void {
		_buttonsGroup.visible = _collapsed;
		removeAnimation();
	}
	
	private function removeAnimation() : Void {
		if (animationComplete != null) {
			Flicker.animator.remove(_tbTween);
			_tbTween = null;
		}
	}
	
	private function triggeredHandler(e:Event) : Void {
		if (_openButton.isSelect)
			_buttonsGroup.visible = true;
		collapsed = _openButton.isSelect;
	}
	
	private function removeLayoutAnimation() : Void {
		if (_layoutTween != null) {
			Flicker.animator.remove(_layoutTween);
			_layoutTween = null;
		}
	}
	
	private function removeLayoutAnimation1() : Void {
		if (_layoutTween2 != null) {
			Flicker.animator.remove(_layoutTween2);
			_layoutTween2 = null;
		}
	}
	
	public override function dispose() : Void {
		_containerStyleFactory = null;
		_buttonsGroupStyleFactory = null;
		_openButtonStyleFactory = null;
		removeLayoutAnimation();
		removeLayoutAnimation1();
		if (_buttonsGroup != null) {
			_buttonsGroup.removeEventListener(Event.RESIZE, buttonsGroupResizeHandler);
			_buttonsGroup.removeEventListener(Event.CHANGE, buttonsGroupTriggeredHandler);
			_buttonsGroup.removeFromParent(true);
			_buttonsGroup = null;
		}
		if (_container != null) {
			_container.removeFromParent(true);
			_container = null;
		}
		if (_openButton != null) {
			_openButton.addEventListener(Event.TRIGGERED, triggeredHandler);
			_openButton.removeFromParent(true);
			_openButton = null;
		}
		super.dispose();
	}
}