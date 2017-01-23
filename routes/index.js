var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {



    mysqlPool.query('SELECT * FROM ec_system', function (error, results, fields) {
        if (error) throw error;
        res.render('index', {
            title: "Endless Choice",
            stories: results
        });
    });


});


module.exports = router;
