/**
 * ui.comboboxFromLinks code
 * Takes a list (<ul> or <ol>) of links and creates an autocomplete combobox from them
 * 
 * Based on the code provided by jQuery UI team:
 * http://jqueryui.com/autocomplete/#combobox
 * Converted to compatibility with jQuery 1.8.24
 */

var txtdropdown = 'Start Typing ...';
 
function focusintxt(ele){
    var curtxt = ele.value;
    ele.value = (curtxt && curtxt != txtdropdown) ? curtxt : "" ;
};

function focusouttxt(ele){
    var curtxt = ele.value;
    ele.value = (curtxt && curtxt != "") ? curtxt : txtdropdown ; // txtdropdown : ele.value;
};

(function( $ ) {
$.widget( "ui.comboboxFromLinks", {
	options: { title: txtdropdown },
    _create: function() {
        var input,
            that = this,
            list = this.element.hide(),
            selected = this.options.title, // @TODO - use the page heading
                //list.children( ":selected" ), // unused old version of selected
            value = selected,
                //selected.val() ? selected.text() : "",
            wrapper = this.wrapper = $( "<span>" )
                .addClass( "ui-combobox" )
                .insertAfter( list );

        function removeIfInvalid(element) {
            var value = $( element ).val(),
                matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( value ) + "$", "i" ),
                valid = false;
            list.children('li').children('a').each(function() {
                if ( $( this ).text().match( matcher ) ) {
                    this.selected = valid = true;
                    return false;
                }
            });
            if ( !valid ) {
                // remove invalid value, as it didn't match anything
                $( element )
                    .val( value )
                    .attr( "title", value + config.forms.errormsg3[LANG] )
                list.val( "" );
                input.data( "autocomplete" ).term = "";
                return false;
            }
        }

        input = $( "<input>" )
            .appendTo( wrapper )
            .val( value )
            .attr( "title", "" )
            .attr( "onfocusin", "focusintxt(this)")
            .attr( "onfocusout", "focusouttxt(this)")
            .addClass( "ui-state-default ui-combobox-input" )
            .autocomplete({
                delay: 0,
                minLength: 0,
                source: function( request, response ) {
                    var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                    response( list.children('li').children('a').map(function() {
                        var text = $( this ).text();
                        if ( $( this ).attr('href') && matcher.test(text) ) {
                            text = text.replace("&", "&amp;"); // Needs to encode ampersand, for RegExp to work
                            return {
                                label: request.term ? text.replace( // when search in progress, make typed search-terms bold
                                    new RegExp(
                                        "(?![^&;]+;)(?!<[^<>]*)(" +
                                        $.ui.autocomplete.escapeRegex(request.term) +
                                        ")(?![^<>]*>)(?![^&;]+;)", "gi"
                                    ), "<strong>$1</strong>" ) : text,
                                value: text.replace("&amp;", "&"), // Decode ampersand again before sending back as value to set in the search box
                                option: this
                            };
                        }
                    }) );
                },
                select: function( event, ui ) {
                    ui.item.option.selected = true;
                    that._trigger( "selected", event, {
                        item: ui.item.option
                    });
                },
                change: function( event, ui ) {
                    if ( !ui.item )
                        return removeIfInvalid( this );
                }
            })
            .addClass( "ui-widget ui-widget-content ui-corner-left" );

        input.data( "autocomplete" )._renderItem = function( ul, item ) {
            return $( "<li>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + item.label + "</a>" )
                .appendTo( ul );
        };

        $( "<a>" )
            .attr( "tabIndex", -1 )
            .attr( "title", "Show All Items" )
            .appendTo( wrapper )
            .button({
                icons: {
                    primary: "ui-icon-triangle-1-s"
                },
                text: 'Show all items'
            })
            .removeClass( "ui-corner-all" )
            .addClass( "ui-corner-right ui-combobox-toggle" )
            .click(function() {
                // close if already visible
                if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
                    input.autocomplete( "close" );
                    removeIfInvalid( input );
                    return;
                }

                // work around a bug (likely same cause as #5265)
                $( this ).blur();

                // pass empty string as value to search for, displaying all results
                input.autocomplete( "search", "" );
                input.focus();
            });
    },

    destroy: function() {
        this.wrapper.remove();
        this.element.show();
        $.Widget.prototype.destroy.call( this );
    }
});
})( jQuery );