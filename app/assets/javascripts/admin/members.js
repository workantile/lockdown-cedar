$(document).ready(function () {
	$('#plan, #type').change(function () {
		$.ajax({
			url: $(this).attr('data-url'),
			data: { type: $("#type option:selected").text(), 
					plan: $("#plan option:selected").text() 
				  },
			dataType: "script"
		});
	});
});
$("body").on({
    ajaxStart: function() { 
        $(this).addClass("loading"); 
    },
    ajaxStop: function() { 
        $(this).removeClass("loading"); 
    }    
});