package com.flicker.core;

import js.Browser;
import js.html.Location;

import com.flicker.animation.Delayer;
import com.flicker.animation.IAnimatable;
import com.flicker.controls.Screen;
import com.flicker.controls.ScreenNavigatorItem;
import com.flicker.controls.super.FlickerControl;
import com.flicker.display.DisplayObject;
import com.flicker.events.Event;
import com.flicker.core.Router;

/**
 * Маршрутизация
 * @author Evgenii Grebennikov
 */
class Router 
{
	public static var current:Router;
	
	public static var isInitialized:Bool = false;
	
	/**
	 * Задаются переопределения для ссылок
	 */
	public static function defaultLinks(map:Array<{address:String, def:String}>) : Void {
		_defaultLinks = map;
		for (i in map) {
			_defaultLinksMap.push(i.address);
		}
	}
	private static var _defaultLinksMap:Array<String> = [];
	private static var _defaultLinks:Array<{address:String, def:String}> = [];
	
	private static function replaceToDefaultIfNeeded(address:String) : String {
		var result:String = address;
		var ind:Int = _defaultLinksMap.indexOf(address);
		if (ind >= 0 && address == _defaultLinks[ind].address)
			result = _defaultLinks[ind].def;
		return result;
	}
	
	public var location(get, never) : Location;
	private var _location:Location;
	private function get_location():Location {
		return _location;
	}
	
	private var _startAddress:String = '';
	
	public function new(rootRouter:Route, screen:FlickerControl) {
		current = this;
		_location = Browser.window.location;
		_startAddress = _location.hash;
		Browser.window.onhashchange = function() {
			navigateTo(_location.hash);
		};
		rootRouter.setRouter(this);
		if (!screen.isInitialized) {
			screen.addEventListener(Event.INITIALIZE, function() : Void {
				if (isInitialized)
					navigateTo(_location.hash);
			});
			return;
		}
	}
	
	public function start(address:String) : Void {
		var sAddress:String = address;
		var startChain:Array<String> = parseUrl(_startAddress);
		if (startChain.length > 0)
			sAddress = _startAddress;
		change(sAddress);
	}
	
	public function change(address:String) : Void {
		address = replaceToDefaultIfNeeded(address);
		_location.hash = address;
	}
	
	public function navigateTo(address:String) : Void {
		address = replaceToDefaultIfNeeded(address);
		var chain:Array<String> = parseUrl(address);
		navigate(chain, ScreenNavigatorItem.getScreenByAddress("#"));
	}
	
	private function getLocalAddress(address:String) : String {
		var chain:Array<String> = this.parseUrl(_location.hash);
		if (chain.length > 0) {
			chain.splice(chain.length - 1, 1);
			chain.push(address);
		}
		var result:String = '';
		for (i in chain) {
			result += i + '/';
		}
		return result;
	}
	
	private function changeAddress(chain:Array<String>) : String {
		var s:String = StringTools.replace(_location.origin, "#", '') + '/#';
		for (r in chain) {
			s += r + '/';
		}
		return s;
	}
	
	private var _delayer:IAnimatable;
	
	private function removeDelayer() :Void {
		if (_delayer != null) {
			Flicker.animator.remove(_delayer);
			_delayer = null;
		}
	}
	
	private function check(chain:Array<String>, screen:ScreenNavigatorItem) : Void {
		removeDelayer();
		_delayer = Flicker.animator.delayCall(navigate, 1, [chain, screen]);
	}
	
	private function navigate(chain:Array<String>, screen:ScreenNavigatorItem) : Void {
		var lastScreen:ScreenNavigatorItem = screen;
		if (lastScreen == null) {
			check(chain, screen);
			return;
		}
		if (!lastScreen.route.owner.isInitialized) {
			check(chain, screen);
			/*lastScreen.route.owner.addEventListener(Event.INITIALIZE, function() : Void {
				navigate(chain, lastScreen);
			});*/
			return;
		}
		var i:Int = 0;
		for (addr in chain) {
			i ++;
			var nextScreen:ScreenNavigatorItem = ScreenNavigatorItem.getScreenByAddress(addr);
			if (nextScreen == null) {
				check(chain, screen);
				return;
			}
			if (!nextScreen.route.owner.isInitialized) {
				check(chain, screen);
				/*nextScreen.route.owner.addEventListener(Event.INITIALIZE, function() : Void {
					navigate(chain, nextScreen);
				});*/
				return;
			} else {
				removeDelayer();
				nextScreen.dispatchEventWith(Event.CHANGE_ROUTE, true, {address:addr, isEnd: i == chain.length});
			}
			lastScreen = nextScreen;
			if (i == chain.length)
				removeDelayer();
		}
	}
	
	public function parseUrl(url:String) : Array<String> {
		var str:String = url;
		var result:Array<String> = new Array<String>();
		while (str.length > 0) {
			var ind:Int = str.indexOf('/');
			var routeAddr:String = ind == -1 ? str : str.substring(0, ind);
			var end:Int = routeAddr.length + (ind == -1 ? 0 : 1);
			str = str.substr(end);
			result.push(routeAddr);
		}
		return result;
	}
	
	public function dispose() : Void {}
}

class RouteAddress {
	private var _origin:String;
	public var origin(get, never):String;
	private function get_origin():String{
		return _origin;
	}
	private var _params:String;
	public var params(get, never):String;
	private function get_params():String{
		return _params;
	}
	public function new(address:String) {
		var ind:Int = address.indexOf('::');
		if (ind > -1) {
			_origin = address.substring(0, ind);
			var end:Int = _origin.length + (ind == -1 ? 0 : 2);
			_params = address.substr(end);
		} else {
			_origin = address;
			_params = '';
		}
	}
}

class Route {
	
	private var _location:Location;
	
	private var _address:RouteAddress;
	public var address(get, set) : RouteAddress;
	private function set_address(v:RouteAddress) : RouteAddress {
		if (_address != v)
			_address = v;
		return get_address();
	}
	private function get_address() : RouteAddress {
		return _address;
	}
	
	private var _router:Router;
	public var router(get, never):Router;
	private function get_router():Router {
		return _router;
	}
	
	public function setRouter(router:Router) : Void {
		_router = router;
	}
	
	private var _owner:FlickerControl;
	public var owner(get, never):FlickerControl;
	private function get_owner():FlickerControl {
		return _owner;
	}
	
	public function new(owner:FlickerControl, address:String) {
		_owner = owner;
		_address = new RouteAddress(address);
		_location = Browser.window.location;
	}
	
	public function parseUrl(url:String) : Array<String> {
		return _router.parseUrl(url);
	}
	
	public function navigateTo(address:String) : Void {
		_router.navigateTo(address);
	}
}