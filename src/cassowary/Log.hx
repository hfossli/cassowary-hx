package cassowary;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

/** A macro based logging class.
    use an initilization macro to set the log level, filter, exclude values and width.
     - these are passed to the logging system from haxe flags
     --macro cassowary.Log.level(2); //set the log level, log=1, _debug=2, _verbose=3, _verboser=4
     --macro cassowary.Log.filter('expression,simplexsolver');  //comma list of inlcude-only logs
     --macro cassowary.Log.exclude('variable,constraint'); //comma list of excluded logs
     --macro cassowary.Log.width(32); //column width
 */
class Log {

        //default to log
    @:noCompletion public static var _level : Int = 1;
    @:noCompletion public static var _filter : Array<String>;
    @:noCompletion public static var _exclude : Array<String>;

    @:noCompletion public static var _log_width : Int = 16;

    macro public static function level( __level:Int ) : haxe.macro.Expr {

        #if !display
            trace("/ cassowary / set log level to " + __level );
        #end

        _level = __level;

        return macro null;

    } //level

    macro public static function filter( __filter:String ) : haxe.macro.Expr {

        #if !display
            trace("/ cassowary / setting filter : " + __filter );
        #end

        _filter = __filter.split(',');

        var _index = 0;
        for(_f in _filter) {
            _filter[_index] = StringTools.trim(_f);
            _index++;
        }

        return macro null;

    } //filter

    macro public static function exclude( __exclude:String ) : haxe.macro.Expr {

        trace("/ cassowary / setting exclude : " + __exclude );

        _exclude = __exclude.split(',');

        var _index = 0;
        for(_e in _exclude) {
            _exclude[_index] = StringTools.trim(_e);
            _index++;
        }

        return macro null;

    } //exclude

    macro public static function width( _width:Int ) : haxe.macro.Expr {

        trace("/ cassowary / set log width to " + _width );

        _log_width = _width;

        return macro null;

    } //width

        //This macro uses the defined log level value to reject code that
        //shouldn't even exist at runtime , like low level debug information
        //and logging by injecting or not injecting code
    macro public static function log( value:Dynamic ) : Expr {

        var _file = Path.withoutDirectory(_get_log_file());
        var _context = Path.withoutExtension(_file).toLowerCase();
        var _spaces = _get_spacing(_file);

        for(meta in Context.getLocalClass().get().meta.get()) {
            if(meta.name == ':log_as') {
                var _str = switch(meta.params[0].expr) {
                    case EConst(CString(str)): _context = str;
                    default: throw 'type should be string constant like "name" for log_as meta flag';
                }
            }
        } //for each meta

        var _log = (_level > 0);

            if(_filter != null && (_filter.indexOf(_context) == -1)) {
                _log = false;
            }

            if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
                _log = false;
            }

        if(_log) {
            return macro @:pos(Context.currentPos()) trace('${_spaces}i / $_context / ' + $value);
        }

        return macro null;

    } //log

    macro public static function _debug( value:Dynamic ) : Expr {

        var _file = Path.withoutDirectory(_get_log_file());
        var _context = Path.withoutExtension(_file).toLowerCase();
        var _spaces = _get_spacing(_file);

        for(meta in Context.getLocalClass().get().meta.get()) {
            if(meta.name == ':log_as') {
                var _str = switch(meta.params[0].expr) {
                    case EConst(CString(str)): _context = str;
                    default: throw 'type should be string constant like "name" for log_as meta flag';
                }
            }
        } //for each meta

        var _log = (_level > 1);

            if(_filter != null && (_filter.indexOf(_context) == -1)) {
                _log = false;
            }

            if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
                _log = false;
            }

        if(_log) {
            return macro @:pos(Context.currentPos()) trace('${_spaces}d / $_context / ' + $value);
        }

        return macro null;

    } //_debug

    macro public static function _verbose( value:Dynamic ) : Expr {

        var _file = Path.withoutDirectory(_get_log_file());
        var _context = Path.withoutExtension(_file).toLowerCase();
        var _spaces = _get_spacing(_file);

        for(meta in Context.getLocalClass().get().meta.get()) {
            if(meta.name == ':log_as') {
                var _str = switch(meta.params[0].expr) {
                    case EConst(CString(str)): _context = str;
                    default: throw 'type should be string constant like "name" for log_as meta flag';
                }
            }
        } //for each meta

        var _log = (_level > 2);

            if(_filter != null && (_filter.indexOf(_context) == -1)) {
                _log = false;
            }

            if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
                _log = false;
            }

        if(_log) {
            return macro @:pos(Context.currentPos()) trace('${_spaces}v / $_context / ' + $value);
        }

        return macro null;

    } //_verbose

    macro public static function _verboser( value:Dynamic ) : Expr {

        var _file = Path.withoutDirectory(_get_log_file());
        var _context = Path.withoutExtension(_file).toLowerCase();
        var _spaces = _get_spacing(_file);

        for(meta in Context.getLocalClass().get().meta.get()) {
            if(meta.name == ':log_as') {
                var _str = switch(meta.params[0].expr) {
                    case EConst(CString(str)): _context = str;
                    default: throw 'type should be string constant like "name" for log_as meta flag';
                }
            }
        } //for each meta

        var _log = (_level > 3);

            if(_filter != null && (_filter.indexOf(_context) == -1)) {
                _log = false;
            }

            if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
                _log = false;
            }

        if(_log) {
            return macro @:pos(Context.currentPos()) trace('${_spaces}V / $_context / ' + $value);
        }

        return macro null;

    } //_verboser


//Internal Helpers


    static function _get_spacing(_file:String ) {

        var _spaces = '';

            //the magic number here is File.hx[:1234] for the trace listener log spacing
        var _trace_length = _file.length + 4;
        var _diff : Int = _log_width - _trace_length;
        if(_diff > 0) {
            for(i in 0 ... _diff) {
                _spaces += ' ';
            }
        }

        return _spaces;

    } //_get_spacing

    macro static function _get_log_file() {
        return macro Context.getPosInfos(Context.currentPos()).file;
    } //get_log_context

} // Log