$(document).ready(function () {
	$(this).on({
	    ajaxStart: function() {
	        $('.loader').addClass('visible');
	    },
	    ajaxStop: function() {
	        $('.loader').removeClass('visible');
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