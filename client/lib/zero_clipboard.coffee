Meteor.startup ->
	ZeroClipboard.setDefaults( { moviePath: '/assets/ZeroClipboard.swf' } )

initZeroClip = ($button, $input) ->
	clip = new ZeroClipboard($button)
	clip.on 'load', ( client, args ) ->
		$button.show()
	clip.on 'complete', ( client, args ) ->
		link = $input.val()
		$input.val('Copied to clipboard')
		wait 1500, =>
			$input.val(link)