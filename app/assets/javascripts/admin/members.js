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

	$(this).on({
	    ajaxStart: function() {
	        $('.loader').addClass('visible');
	    },
	    ajaxStop: function() {
	        $('.loader').removeClass('visible');
	    }
	});

	$('.invoice_button').click(function () {
		$.ajax({
			url: $(this).attr('data-url'),
			data: { _method: "put" },
			type: "post",
			dataType: "script"
		});
	});

	$('#delete-updates').click(function () {
		$.ajax({
			url: $(this).attr('data-url'),
			data: { _method: "delete" },
			type: "post"
		});
	});

	$('#member_member_type').change(function () {
		$('input:radio[name="member_type_timing"]').attr('disabled', false);
	});

	$('#member_billing_plan').change(function () {
		$('input:radio[name="billing_plan_timing"]').attr('disabled', false);
	});
});
