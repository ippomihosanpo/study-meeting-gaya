milkcocoa = new MilkCocoa('hotin42a88s.mlkcca.com')
dsReaction = milkcocoa.dataStore("reaction")
dsCount = milkcocoa.dataStore("reaction_cout")
date = null

maxHeight = 0
maxWidth = 0
reactions = {
	nobi1:'おひぃ↓',
	nobi2:'おひぃ↑',
	oyo:'きになるー',
	kou:'ほぉんとに！？',
	miho:'ふんふん',
	ono:'なんでやねん'
}
results = {
	nobi1:0,
	nobi2:0,
	oyo:0,
	kou:0,
	miho:0,
	ono:0
}
resultSize = 6
totalCount = 0

# リアクションを表示する位置をランダムで取得
getRandomPos = (type, limit) ->
	max = if type == 'x' then limit - 92 else limit - 10
	return (Math.floor((Math.random() * (max+1) / limit) * 100))

# リアクション情報をMilkCocoaに送信する
sendReaction = (type, x, y) ->
	# リアクションを送信
	dsReaction.push {
		date: date,
		type: type,
		x: x,
		y: y
	}, (e) ->
	showReaction(type, x, y)
	# リアクション累計を送信
	dsReaction.get "count#{date}#{type}", (err, data) ->
		if err
			# 初回(not foundがerrに入る)はデータがないので1で初期化
			if err == 'not found'
				dsReaction.set "count#{date}#{type}", 'count': '1'
				return
		# 接続数を取得し+1する
		count = parseInt(data.value.count, 10) + 1
		dsReaction.set "count#{date}#{type}", 'count': count
		return


# リアクションを画面に表示させる
showReaction = (type, x, y) ->
	$('#reactions').append("<span class='reaction #{type}' style='top:#{y}%;left:#{x}%'>#{reactions[type]}</span>")

# リアクションの結果を表示する
@showResult = (date) ->
	getResults(date).done (data) ->
		$.each results, (key, value) ->
			resultWidth = Math.floor(results[key] / totalCount * 100)
			$(".result.#{key}").css("width", "#{resultWidth}%")
			$(".result.#{key} span").html("#{results[key] || 0} #{reactions[key]}")
		return

getResults = (date) ->
	dfd = $.Deferred()
	index = 0
	totalCount = 0
	$.each results, (key, value) ->
		dsReaction.get "count#{date}#{key}", (err, data) ->
			if err
				# 初回(not foundがerrに入る)はデータがないので1で初期化
				if err == 'not found'
					dsReaction.set "count#{date}#{key}", 'count': '0'
			else
				count = parseInt(data.value.count, 10)
			results[key] = count
			totalCount = totalCount + count
			if index == resultSize - 1
				dfd.resolve(totalCount)
			index++
	return dfd.promise()

$(document).ready ->
	date = $("#container").attr("data-date")
	maxHeight = $('#reactions').height()
	maxWidth = $('#reactions').width()
	# MilkCocoaからリアクションを取得、画面に表示する
	dsReaction.stream().size(500).next (err, datas) ->
		datas.forEach (data) ->
			if date == data.value.date
				showReaction(data.value.type, data.value.x, data.value.y)
			return
		return
	showResult(date)

	# 他の人がリアクションしたかを監視
	dsReaction.on 'push', (data) ->
		showReaction(data.value.type, data.value.x, data.value.y)
		showResult(date)
		return

# リアクションボタン押下時
$(document).on 'click', '.button', ->
	$('.active').removeClass('active')
	$(this).addClass('active')
	type = $(this).attr("data-sound")
	# おひぃ鳴らす
	$('#sound-' + type)[0].play()
	x = getRandomPos('x', maxWidth)
	y = getRandomPos('y', maxHeight)
	# データ送信
	sendReaction(type, x, y)