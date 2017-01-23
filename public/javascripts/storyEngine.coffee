class storyEngine
	app_trophyID = ''
	app_willVibrate = 'NO'
	app_hint = ''
	app_admobID = ''
	currentPassword = '#{wid}'
	typing_speed = '#{script.typing}'
	passedFrames = [1]
	record =
		buttonId: '#{script.buttonId}'
		pageId: '#{pageId}'
		worldId: '#{wid}'

	getPassword = -> currentPassword
	getTrophy = -> app_trophyID
	getVibration = -> app_willVibrate
	getHint = -> app_hint
	getAds = -> app_admobID
	setAdmobID = () ->
		app_admobID = '#{s}'

	ec_save1 = ->
		if typeof currentPassword == 'undefined' or currentPassword == ''
			toast '這兒不能儲存'
		else
			window.localStorage['save1' + record.worldId] = currentPassword
			toast '己儲存'

	ec_load1 = ->
		if localStorage.getItem('save1' + record.worldId) == null
			toast '沒有存檔'
			return
		toast '載入中'
		setTimeout (->
			$('#load_code').val window.localStorage['save1' + record.worldId]
			$('#load_form').submit()
		), 500

	ec_embed = (target, a) ->
		$('#' + target).load 'check.php?worldid=' + record.worldId + '&id=' + a

	ec_get = (dom) ->
		if document.getElementById(dom) == null
			console.log 'no dom:' + dom
		else
			return document.getElementById(dom).value

	ec_set = (dom, val) ->
		if document.getElementById(dom) == null
			console.log 'no dom:' + dom
		else
			document.getElementById(dom).value = val

	ec_add = (strvar, amount) ->
		prevVal = parseFloat(ec_get(strvar))
		if isNaN(prevVal)
			prevVal = 0
		ec_set strvar, prevVal + amount


	ec_app = (function_name, function_args) ->
		switch function_name
			when 'vibrate'
				app_willVibrate = 'YES'
			when 'ads_interstitial'
				setAdmobID()
			when 'trophy'
				app_trophyID = app_trophyID + ',' + function_args
			when 'hint'
				app_hint = function_args

	ec_push = (dom_id, val) ->
		$('[id=' + dom_id + ']').html val

	ec_show = (dom) ->
		$('[id="' + dom + '"]').css 'display', 'inline'

	ec_hide = (dom) ->
		$('[id="' + dom + '"]').hide()

	ec_hideall = (dom) ->
		$(dom).hide()

	ec_dice = (num) ->
		Math.floor(Math.random() * num) + 1

	ec_hide_option = (id) ->
		$('[buttonId="' + id + '"]').hide()

	ec_lazy_push = (arr) ->
		for arg of arguments
			ec_push arg,ec_get(arg)

	ec_previous_page = ->
		record.buttonId

	ec_this_page = ->
		record.pageId

	ec_show_choices = ->
		$('#choices').show()
		$('.page_choices').each ->
			if @innerText == ''
				$(this).hide()
		$('a[button_id]').on('click', ->
			save_page if $.isNumeric($(this).attr('to')) then $(this).attr('to') else ec_get($(this).attr('to')) $(this).attr('button_id')
		).css 'cursor', 'pointer'

	go = (page, ec_input) ->
		try
			loaded page, ec_input
		catch err
		record.buttonId = ec_input
		$.post window.location, record, (result) ->
			onLoadFinished result

	ec_previous_button_id = ->
		record.buttonId

	ec_set_title = (str) ->
		$("#title").html str

	ec_hide_option = (id) ->
		if Array.isArray(id)
			$.each id, (index, value) ->
				ec_hide_option value
		else
			$('#choice' + id).hide()

	ec_show_option = (id) ->
		if Array.isArray(id)
			$.each id, (index, value) ->
				ec_show_option value
		else
			$('#choice' + id).show()

	ec_passed = (id) ->
		id in passedFrames

	if typing_speed >= 1
		count = 0
		content = undefined

	onLoadFinished = (result) ->
		passedFrames.push result.id
		$("#content").html result.content
		$("#title").html result.title
		record = result.record

		eval result.script

		$("[ec_style='fade_size']").each () ->
			from = parseFloat($(this).attr('from'))
			to = parseFloat($(this).attr('to'))
			intSpans = parseInt(Math.abs(from - to) * 10)
			intCharPerSpan = Math.round($(this).text().length / intSpans)
			regex = new RegExp('.{1,' + intCharPerSpan + '}', 'g')
			chunks = $(this).text().match(regex)
			#console.log(".{1,"+intCharPerSpan+"}");
			#console.log(chunks);
			strHtml = ''
			i = 0
			while i <= intSpans
				strHtml = strHtml.concat '<span style=\'font-size:' + parseFloat(from + i * 0.1) + 'em\'>' + chunks[i] + '</span>'
				i++
			$(this).html "<span style='line-height:normal'>" + strHtml + "</span>"
		if typing_speed >= 1
			content = $('#story_content').html()
			typeWrite content
		else
			showChoices()

	typeWrite = ->
		if count++ <= content.length
			$ '#story_content'
				.html content.substring(0, count) + '|'
			setTimeout 'type_write()', typing_speed
		else
			showChoices()

	toast = (msg) ->
		$ '<div><h3>' + msg + '</h3></div>'
			.css
				display: 'block'
				opacity: 0.90
				position: 'fixed'
				padding: '7px'
				'text-align': 'center'
				background: 'yellow'
				width: '270px'
				left: ($(window).width() - 284) / 2
				top: $(window).height() / 2
			.appendTo($('body'))
			.delay(1500)
			.fadeOut 400, -> $(this).remove()
