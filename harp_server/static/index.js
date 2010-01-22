(function($) {
 	var log = function(message) {
		if(window.console) { console.log(message) };
	};

 	var getNode = function($parentNode, id, noHighlight) {
		$.get('/node/' + id + '/children', null, function(data, textStatus) {
			$parentNode.append(data);
			attachEvents($parentNode);
			$parentNode.parent().css('background-color', 'inherit');
			log($parentNode.children('ul.children'));
			if(!noHighlight) {
				$parentNode.children('ul.children').css('background-color', 'yellow');
			}
		});
	};

	var attachEvents = function($node) {
		$node.children('ul.children').children('li').each(function() {
			var $li = $(this);
			$li.children('.expand').children('a').click(function() {
				expandChildren($li);
				$li.children('.expand').hide();
				$li.children('.collapse').show();
				return false;
			});
			$li.children('.collapse').children('a').click(function() {
				$li.children('ul.children').hide();
				$li.children('.collapse').hide();
				$li.children('.expand').show();
				return false;
			});
		});
	};

	var expandChildren = function($li) {
		if($li.children().is('ul.children')) {
			$li.children('ul.children').show();
		} else {
			var id = parseInt($li.children('.id').text());
			getNode($li, id);
		}
	}

	$(function() {
		getNode($('#root'), 0, true);
	});
})(jQuery);
