var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/:storyId', function(req, res, next) {
	mysqlPool.query('SELECT * FROM ec_system WHERE id = ?;' +
		'SELECT varname FROM ec_variables WHERE wid=?;',
		[req.params.storyId,req.params.storyId],
		function (error, results, fields) {
		if (error) throw error;
		var keys = _.map(results[1],'varname');
		res.render('story', {
			story: results[0][0],
			variableJson: _.zipObject(keys, _.map(keys, function() {return ''}))
		});
	});
});
router.get('/:storyId/:pageId', function(req, res, next) {
	mysqlPool.query(
		'SELECT * FROM ec_system WHERE id = ?;' +
		'SELECT * FROM ec_pages WHERE wid = ? AND id = ?;',
		[req.params.storyId,req.params.storyId,req.params.pageId],
		function (error, results, fields) {
			if (error) throw error;
			console.time("render");
			systemResult=results[0][0];
			pageResult=results[1][0];
			res.render('story', {
				title: pageResult.title,
				content: php.nl2br(pageResult.content),
				pageId: req.params.pageId,
				wid: req.params.storyId,
				choices: [
					[pageResult.c1,pageResult.c1to],
					[pageResult.c2,pageResult.c2to],
					[pageResult.c3,pageResult.c3to],
					[pageResult.c4,pageResult.c4to],
					[pageResult.c5,pageResult.c5to],
					[pageResult.c6,pageResult.c6to]
				],
				script: {
					typing: parseInt(pageResult.typing),
					buttonId: req.body.buttonId,
					admobId: systemResult.admob_id
				}
			});
			console.timeEnd("render");
		}
	);

});
module.exports = router;
