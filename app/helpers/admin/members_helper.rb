module Admin::MembersHelper
	def build_filters
		type_list = Member::MEMBER_TYPES.collect { |type| [type, type] }
		type_list << ['all', 'all']
		plan_list = Member::BILLING_PLANS.collect { |plan| [plan, plan] }
		plan_list << ['all', 'all']
		form_tag(admin_members_url, :method => 'get') do
			label_tag(:type, "Filter by member type") +
			select_tag(:type, options_for_select(type_list, params[:type])) +
			label_tag(:plan, "Filter by billing plan") +
			select_tag(:plan, options_for_select(plan_list, params[:plan])) +
			submit_tag("Filter list", :class => 'btn btn-primary')
		end

	end
end
