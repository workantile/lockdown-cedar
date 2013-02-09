$(document).ready(function () {
	$("body").on({
	    ajaxStart: function() { 
	        $(this).addClass("loading"); 
	    },
	    ajaxStop: function() { 
	        $(this).removeClass("loading"); 
	    }    
	});	

	$('#apply-dates').click(function () {
		$.ajax({
			url: $(this).attr('data-url'),
			data: { start_date: $('#start-date').val(),
					end_date: $('#end-date').val()
				  },
			dataType: "script"
		});
		return false;
	});

	$('#start-date').datepicker();
	$('#end-date').datepicker();
});