import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // English
    'en_US': {
      // Onboarding
      'onb1_title': 'Connect with Top\nTalent & Brands',
      'onb1_body':
          'The ultimate marketplace connecting visionary brands with verified influencers and agencies.',
      'onb2_title': 'Secure Payments &\nMilestones',
      'onb2_body':
          'Manage campaigns with ease. Funds are held securely and released only when milestones are met.',
      'onb3_title': 'Scale Your \nImpact',
      'onb3_body':
          'Whether you’re launching a product or building your personal brand, grow faster with our platform.',
      'btn_next': 'Next',
      'btn_get_started': 'Get Started',
      'btn_skip': 'Skip',

      // Login
      'login_title': 'Login',
      'login_subtitle': 'Good to see you back!',
      'login_phone_hint': 'Phone Number',
      'login_password_hint': 'Password',
      'login_forgot_password': 'Forgot Password?',
      'login_button': 'Login',
      'login_no_account': 'Don’t have an account?',
      'login_sign_up': 'Sign Up',

      // Signup (account type)
      'signup_title': 'Sign Up',
      'signup_subtitle': 'Select your account type',
      'signup_brand_title': 'Brand',
      'signup_brand_subtitle': 'Promote My Business',
      'signup_influencer_title': 'Influencer',
      'signup_influencer_subtitle': 'Monetize My Reach',
      'signup_agency_title': 'Ad Agency',
      'signup_agency_subtitle': 'Manage Client Campaigns',
      'signup_continue': 'Continue',

      'infl_profile_title': 'Hey, Influencer!',
      'brand_profile_title': 'Ready to launch?',
      'agency_profile_title': 'Hello, Agency!',
      'infl_profile_subtitle': "Let\'s Get You Set Up!",
      'brand_profile_subtitle': "Let's Grow your brand!",
      'infl_profile_section_title': 'Profile Details',
      'brand_name_label': 'Brand name *',
      'brand_name_hint': 'Enter your brand/Business Name',
      'infl_first_name_label': 'First Name *',
      'infl_first_name_hint': 'Enter Your First Name',
      'infl_last_name_label': 'Last Name *',
      'infl_last_name_hint': 'Enter Your Last Name',
      'infl_email_label': 'Email Address *',
      'infl_email_hint': 'Ex: johndoe@email.com',
      'infl_phone_label': 'Phone Number *',
      'infl_phone_hint': 'Ex: +8801234567890',

      'btn_continue': 'Continue',
      'auth_already_have_account': 'Already have an account?',
      'auth_login': 'Login',

      // ✅ OTP / Verification page
      'otp_title': 'Verification Code\nSent!',
      // use trParams to inject phone: 'otp_subtitle'.trParams({'phone': phone})
      'otp_subtitle': 'We sent a code to @phone',
      'otp_didnt_receive': "Didn't receive the code?",
      'otp_resend': 'Resend',
      'otp_continue': 'Continue',
      'otp_have_account': 'Already have an account?',
      'otp_login': 'Login',

      // Phone verified page
      'phone_verified_title': 'Phone Number\nVerified!',
      'phone_verified_body':
          "Great! Your phone number is now linked to your account. Let's continue by setting up your profile.",

      'influ_addr_title': 'Hey, Partner!',
      'agency_addr_title': 'Hello, Partner!',
      'brand_addr_title': 'Hello, Partner!',
      'influ_addr_subtitle': 'Where should we send the good stuff?',
      'brand_addr_subtitle': 'Establish Your Business Presence',
      'agency_addr_subtitle': 'Establish Your Business Presence',
      'influ_addr_body':
          'Awesome brands need to know where to send their products for review. Let them know where to find you!',
      'brand_addr_body':
          'Let\'s get your office location registered to connect with local and regional talents!',
      'agency_addr_body':
          'Let\'s get your office location registered to connect with local and regional clients.',
      'influ_addr_info':
          'You can always change the product drop off point before accepting any deals!',
      'influ_addr_section_title': 'Address',
      'influ_addr_thana_label': 'Thana *',
      'influ_addr_thana_hint': 'Select Thana',
      'influ_addr_zilla_label': 'Zilla *',
      'influ_addr_zilla_hint': 'Select Zilla',
      'influ_addr_full_label': 'Full Address *',
      'influ_addr_full_hint': 'Enter Full Address',
      'influ_addr_full_error': 'Please enter your full address',
      'influ_addr_select_error': 'Please select an option',
      'influ_addr_thana_sheet_title': 'Select Thana',
      'influ_addr_zilla_sheet_title': 'Select Zilla',

      'influ_social_title': 'Time to shine!',
      'brand_social_title': 'Time to shine!',
      'agency_social_title': 'Time to shine!',
      'influ_social_subtitle': 'Let your social presence shine!',
      'brand_social_subtitle': 'Let your social presence shine!',
      'agency_social_subtitle': 'Let your social presence shine!',
      'influ_social_body':
          'Think of this as your digital resume for every campaign offer. The more you add, the better!',
      'brand_social_body':
          'Help creators understand your brand\'s voice and aesthetic by linking your active social channels.',
      'agency_social_body':
          'Think of this as your digital resume for every campaign offer. The more you add, the better!',
      'influ_social_info':
          'We\'ll use this to verify your audience and match you with the perfect paid collaborations.',
      'influ_social_section_title': 'Your Social Media Links',
      'influ_social_website_label': 'Website Address (If You Have)',
      'influ_social_website_hint': 'Website Address',
      'influ_social_platform_label': 'Choose Platforms *',
      'influ_social_platform_hint': 'Select Platform',
      'influ_social_platform_error': 'Please choose a platform',
      'influ_social_profile_label': 'Profile Link *',
      'influ_social_profile_hint': 'Page Link',
      'influ_social_profile_error': 'Please enter your profile link',
      'influ_social_add_another': '+ Add Another',

      'influ_kyc_title': 'Unlock Payout!',
      'influ_kyc_subtitle': "Let\'s get you ready to earn!",
      'influ_kyc_body':
          'This is a onetime security check to ensure payments are sent to the correct person. Your data is safe with us.',
      'influ_kyc_info':
          'We use this to prevent fraud and secure your account. For more information, please see our Privacy Policy.',
      'influ_kyc_section_title': 'Provide Your NID',
      'influ_kyc_nid_label': 'Your NID Number *',
      'influ_kyc_nid_hint': 'Enter your NID Number',
      'influ_kyc_nid_error': 'Please enter your NID number',
      'influ_kyc_front_label': 'Front Side of NID',
      'influ_kyc_back_label': 'Back Side of NID',
      'influ_kyc_upload_helper': 'PNG, JPEG, PDF (Max 2MB)',
      'influ_kyc_skip': 'Skip',
      'influ_kyc_submit': 'Submit',

      'influ_success_title': 'Welcome aboard!',
      'influ_success_subtitle': 'Your account was created successfully!',
      'influ_success_body':
          'Our team will now securely review your information to complete the verification process.',
      'influ_success_hint':
          'This typically takes 24–48 business hours. We will notify you as soon as your account is verified. In the meantime, you can explore the dashboard and continue updating your profile.',
      'influ_success_btn': 'Explore Dashboard',

      'brand_step1_title': 'Ready to launch?',
      'brand_step1_subtitle': "Let\'s grow your brand!",
      'brand_step1_section_title': 'Profile Details',

      'brand_step1_brand_label': 'Brand Name *',
      'brand_step1_brand_hint': 'Enter your brand / business name',
      'brand_step1_brand_error': 'Please enter your brand or business name',

      'brand_step1_first_label': 'First Name *',
      'brand_step1_first_hint': 'Enter your first name',
      'brand_step1_first_error': 'Please enter your first name',

      'brand_step1_last_label': 'Last Name *',
      'brand_step1_last_hint': 'Enter your last name',
      'brand_step1_last_error': 'Please enter your last name',

      'brand_step1_email_label': 'Email Address *',
      'brand_step1_email_hint': 'Ex: johndoe@email.com',
      'brand_step1_email_error': 'Please enter your email address',
      'brand_step1_email_invalid': 'Please enter a valid email address',

      'brand_step1_phone_label': 'Phone Number *',
      'brand_step1_phone_hint': 'Ex: +8801234567890',
      'brand_step1_phone_error': 'Please enter your phone number',

      'brand_step1_lang_en': 'English',
      'brand_step1_lang_bn': 'বাংলা',

      'brand_step1_footer_title': 'Already have an account?',
      'brand_step1_footer_login': 'Login',

      'brand_tl_title': 'Make it Official!',
      'brand_tl_subtitle': 'Become a Certified Partner',
      'brand_tl_body':
          'Uploading your trade license shows you\'re a legitimate and professional business, ready for serious partnerships.',
      'brand_tl_info':
          'Think of it as the key to the VIP room. Your data is encrypted and secure. For more information, please see our Privacy Policy.',
      'brand_tl_section_title': 'Provide Your Trade License',
      'brand_tl_number_label': 'Your Trade License Number *',
      'brand_tl_number_hint': 'Enter your Trade License Number',
      'brand_tl_number_error': 'Please enter your trade license number',
      'brand_tl_upload_label': 'Upload Trade License',
      'brand_tl_upload_helper': 'PNG, JPEG, PDF (Max 2MB)',
      'brand_tl_skip': 'Skip',
      'brand_tl_continue': 'Continue',

      'brand_tin_title': 'One Final Step!',
      'brand_tin_subtitle': "Establish Your Brand\'s Credibility",
      'brand_tin_body':
          'To comply with financial regulations and enable secure invoicing and payouts, please provide your official business tax and identification numbers.',
      'brand_tin_info':
          'Your data is encrypted and secure. For more information, please see our Privacy Policy.',
      'brand_tin_section_title': 'Provide Your TIN Certification',
      'brand_tin_tin_label': 'Your TIN Number *',
      'brand_tin_tin_hint': 'Enter your TIN Number',
      'brand_tin_tin_error': 'Please enter your TIN Number',
      'brand_tin_upload_label': 'Upload TIN Certificate',
      'brand_tin_upload_helper': 'PNG, JPEG, PDF (Max 2MB)',
      'brand_tin_bin_label': 'Your BIN Number (Optional)',
      'brand_tin_bin_hint': 'Enter your BIN Number',
      'brand_tin_skip': 'Skip',
      'brand_tin_continue': 'Continue',

      'fp_title': 'Forgot\nPassword?',
      'fp_subtitle': 'No worries, we’ll send you reset instructions',
      'fp_input_hint': 'Phone / Email',
      'fp_continue': 'Continue',
      'fp_login_question': 'Already have an account?',
      'fp_login': 'Login',

      'fp_verify_title': 'Verification Code\nSent!',
      'fp_verify_subtitle': 'We sent a code to @phone',
      'fp_resend': 'Didn’t receive the code? Resend',
      'fp_otp_continue': 'Continue',

      'fp_new_title': 'Set New Password',
      'fp_new_subtitle': 'Must be at least 8 characters long',
      'fp_new_password_hint': 'Password',
      'fp_confirm_password_hint': 'Confirm Password',
      'fp_reset_button': 'Reset Password',

      'fp_success_title': 'All set!',
      'fp_success_subtitle': 'Your password has been reset successfully!',
      'fp_success_button': 'Go to My Dashboard',

      'home_locked_hero_title': 'Almost There',
      'home_locked_hero_subtitle':
          'Complete verification to unlock your full dashboard with earnings, active jobs, and new opportunities.',

      'home_locked_verification_title': 'Verification Progress',
      'home_locked_profile_title': 'Complete Your Profile',
      'home_locked_need_help': 'Need Help?',
      'home_locked_help_guide': 'Verification Guide',
      'home_locked_help_support': 'Contact Support',

      'home_locked_basic_info_title': 'Basic Informations',
      'home_locked_basic_info_sub': 'That’s how we are going to reach you',
      'home_locked_social_portfolio_title': 'Social Portfolio',
      'home_locked_social_portfolio_sub': '1 Added · You can always add more',
      'home_locked_nid_title': 'NID',
      'home_locked_nid_sub': 'In Review',
      'home_locked_trade_license_title': 'Trade License',
      'home_locked_trade_license_sub':
          'Declined, document details don\'t match with the provided information',
      'home_locked_tin_title': 'TIN',
      'home_locked_bin_title': 'BIN',
      'home_locked_payment_title': 'Payment Setup',
      'home_locked_verify_email_title': 'Verify Email',
      'home_locked_generic_pending': 'Pending',

      'home_locked_profile_picture_title': 'Add Profile Picture',
      'home_locked_profile_picture_sub': 'That’s how we are going to reach you',
      'home_locked_add_niches_title': 'Add Niches',
      'home_locked_add_skills_title': 'Add Skills',
      'home_locked_add_bio_title': 'Add Bio',

      'home_locked_help_niche':
          'A niche is a focused area of interest, need, or demographic that an influencer or agency focuses on exclusively.',
      'home_locked_help_skills':
          'To be a successful agency, you need a mix of creative, technical, interpersonal, and business skills.',

      'support_contact_title': 'Contact Support',
      'support_helpline_section_title': 'Helpline Numbers',
      'support_email_section_title': 'Email Us',
      'support_help_line_1': 'Help Line 1',
      'support_help_line_2': 'Help Line 2',
      'support_help_line_3': 'Help Line 3',
      'support_time_10_8': '10AM–8PM',

      // Earnings overview (if you want to localize that card too)
      'earnings_overview': 'Earnings Overview',
      'lifetime_earnings': 'Lifetime Earnings',
      'pending_earnings': 'Pending Earnings',

      // Summary row
      'home_active_jobs': 'Active Jobs',
      'home_new_offers_for_you': 'New Offers For You',
      'home_view_all': 'View All',

      // Work in progress
      'home_work_in_progress': 'Work In Progress',
      'home_active_suffix': 'Active',
      'home_view_all_jobs': 'View All Jobs →',
      'home_budget': 'Budget',
      'home_complete_suffix': 'Complete',
      'home_view': 'View',

      // Lifetime summary
      'home_lifetime_summary': 'Lifetime Summary',
      'home_jobs_completed_suffix': 'Jobs Completed',
      'home_top_client': 'Top client',
      'home_last_job': 'Last Job: 12 Dec 2025',

      'home_total_jobs_completed': 'Total Jobs Completed',
      'home_total_earnings': 'Total Earnings',
      'home_total_jobs_declined': 'Total Jobs Declined',
      'home_most_used_platform': 'Most Used Platform',

      'notifications_title': 'Notifications',
      'notifications_mark_all_read': 'Mark All As Read',
      'notifications_new': 'New',
      'notifications_earlier': 'Earlier',
      'notifications_empty': 'No notifications',

      // Top bar
      'topbar_welcome_user': 'Welcome, User!',
      'topbar_ready_to_earn': 'Ready To Earn Today?',

      // Bottom nav
      'nav_home': 'Home',
      'nav_jobs': 'Jobs',
      'nav_earnings': 'Earnings',
      'nav_profile': 'Profile',

      // Common (if not already added)
      'welcome_user': 'Welcome, User!',
      'campaign_details_title': 'Campaign Details',

      // Shipping page
      'shipping_where_to_send': 'Where To Send The Product?',
      'shipping_address_house': 'House',
      'shipping_address_office': 'Office',
      'shipping_default': 'Default',
      'shipping_add_another': '+ Add Another',
      'shipping_confirm_read_terms':
          "Confirm you’ve read the client’s terms & conditions",
      'shipping_accept_license_terms':
          "You accept the user license agreement & terms and condition of our app.",
      'shipping_decline': 'Decline',
      'shipping_accept': 'Accept',

      // address form
      'shipping_address_form_title': 'Address',
      'shipping_address_form_set_default': 'Set Default',
      'shipping_address_form_give_name_label': 'Give A Name',
      'shipping_address_form_give_name_hint': 'Give a name to the address',
      'shipping_address_form_thana_label': 'Thana *',
      'shipping_address_form_thana_hint': 'Select Thana',
      'shipping_address_form_zilla_label': 'Zilla *',
      'shipping_address_form_zilla_hint': 'Select Zilla',
      'shipping_address_form_full_label': 'Full Address *',
      'shipping_address_form_full_hint': 'Enter full address',
      'shipping_address_form_save': 'Save',
      'shipping_address_form_error_title': 'Address',
      'shipping_address_form_error_full_required':
          'Please enter the full address.',
      'shipping_address_custom': 'Address',

      'shipping_thana_banani': 'Banani',
      'shipping_thana_gulshan': 'Gulshan',
      'shipping_thana_dhanmondi': 'Dhanmondi',
      'shipping_thana_mirpur': 'Mirpur',
      'shipping_zilla_dhaka': 'Dhaka',
      'shipping_zilla_chattogram': 'Chattogram',
      'shipping_zilla_sylhet': 'Sylhet',
      'shipping_zilla_rajshahi': 'Rajshahi',
      'shipping_address_form_error_thana_zilla_required':
          'Please select both Thana and Zilla.',

      'language_title': 'Language',
      'language_subtitle': 'Select Your Language Preference',
      'select_language_header': 'Select Your Language',
      'english': 'English',
      'bangla': 'বাংলা',

      'report_log': 'Report Log',
      'flagged': 'Flagged',
      'pending': 'Pending',
      'resolved': 'Resolved',
      'search_hint': 'Search By Campaign Name..',
      'milestone': 'Milestone',
      'hours_ago': 'Hours Ago',
      'date_format': 'Dec 15, 2025',
      'audio_issue': 'Audio Quality Does Not Meet Requirements...',

      // Overview card
      'home_earnings_overview': 'Earnings Overview',
      'home_lifetime_earnings': 'Lifetime Earnings',
      'home_pending_earnings': 'Pending Earnings',

      'home_due_in_days': 'Due: @days Days',
      'home_due_tomorrow': 'Due: Tomorrow',

      // ---------- JOBS ----------
      'jobs_search_hint': 'Search By Job Name, Client Name',
      'jobs_tab_new_offers': 'New Offers',
      'jobs_tab_active_jobs': 'Active Jobs',
      'jobs_tab_active': 'Active',
      'jobs_tab_budgeting_quoting': 'Budgeting & Quoting',
      'jobs_tab_completed': 'Completed',
      'jobs_tab_pending': 'Pending',
      'jobs_tab_draft': 'Draft',
      'jobs_tab_declined': 'Declined',
      'jobs_tab_canceled': 'Canceled',

      'jobs_header_new_offers': 'New Offers Just For You!',
      'jobs_header_active': 'Active Jobs',
      'jobs_header_completed': 'Completed Jobs',
      'jobs_header_pending': 'Pending Payments',
      'jobs_header_declined': 'Declined Jobs',

      'jobs_filter_low_to_high': 'Low To High',
      'jobs_empty': 'No jobs found',

      // ---------- COMMON (reuse across screens) ----------
      'common_view': 'View',
      'common_budget': 'Budget',
      'common_accept': 'Accept',
      'common_decline': 'Decline',
      'common_complete_suffix': 'Complete',
      'common_due_in_days': 'Due: @days Days',
      'common_due_tomorrow': 'Due: Tomorrow',

      // -------- Common --------
      'common_platforms': 'Platforms',
      'common_client': 'Client',
      'common_completed': 'Completed',
      'common_no_deadline': 'No Deadline',
      'common_no_jobs_found': 'No jobs found',

      // Sort / Search
      'jobs_sort_low_to_high': 'Low To High',

      // Due / Remaining
      'label_due_days': 'Due: @days Days',
      'label_due_tomorrow': 'Due: Tomorrow',
      'label_days_remaining': '@days Days Remaining',

      'home_active_badge': '@count Active',
      'home_jobs_completed_line': '@count Jobs Completed',
      'home_progress_complete_line': '@percent% Complete',

      // -------- Jobs Tabs --------
      'jobs_header_active_jobs': 'Active Jobs',
      'jobs_header_completed_jobs': 'Completed Jobs',
      'jobs_header_pending_payments': 'Pending Payments',
      'jobs_header_declined_jobs': 'Declined Jobs',

      // -------- Campaign Details --------
      'campaign_your_profit': 'Your Profit (@percent%)',
      'campaign_deadline': 'Deadline',

      'campaign_quote_details': 'Quote Details',
      'campaign_budget': 'Campaign Budget',
      'campaign_vat_tax': 'VAT/Tax',
      'campaign_total_cost': 'Total Campaign Cost',
      'campaign_request_requote': 'Request To Requote',

      'campaign_payment_milestones': 'Payment Milestones',
      'campaign_progress': 'Progress',
      'campaign_paid_of_total': '@paid Of @total Paid',

      'campaign_total_earnings': 'Total Campaign Earnings',
      'campaign_withdrawal_request': 'Withdrawal Request',

      'campaign_brief': 'Campaign Brief',
      'campaign_content_assets': 'Content Assets',
      'campaign_terms_conditions': 'Terms & Conditions',
      'campaign_brand_assets': 'Brand Assets',

      // Brief content
      'campaign_goals': 'Campaign Goals',
      'campaign_goals_desc':
          'Promote our new summer skincare line to Gen Z and millennial audiences. Focus on natural ingredients and sustainable packaging',
      'campaign_content_requirements': 'Content Requirements',

      'campaign_req_1': 'Minimum 1 feed post & 2–3 stories per platform.',
      'campaign_req_2': 'Use the provided brand assets and hashtags.',
      'campaign_req_3':
          'Tag the official brand account in every content piece.',

      'campaign_dos_donts': 'Do’s & Don’ts',
      'campaign_dos': 'Do’s',
      'campaign_dos_1': 'Show authentic product usage in daily life.',
      'campaign_dos_2': 'Keep captions clear and brand-safe.',
      'campaign_dos_3': 'Highlight key campaign messages and benefits.',
      'campaign_donts': 'Don’ts',
      'campaign_donts_1': 'Avoid competing brand placements in the same frame.',
      'campaign_donts_2': 'Do not mislead or over-claim performance.',
      'campaign_donts_3': 'Avoid sensitive or inappropriate context.',

      // Assets
      'campaign_asset_logo_pack': 'Brand Logo Pack',
      'campaign_asset_demo_video': 'Product Demo Video',
      'campaign_asset_guidelines': 'Brand Guidelines',
      'campaign_asset_facebook_page': 'Facebook Page',
      'campaign_asset_facebook_sub': 'Brand’s official page link',

      // Terms
      'campaign_reporting_requirements': 'Reporting Requirements',
      'campaign_report_1':
          'Submit analytics screenshots within 7 days after content goes live.',
      'campaign_report_2':
          'Share reach, impressions, link clicks and saves where applicable.',
      'campaign_usage_rights': 'Usage Rights',
      'campaign_usage_1':
          'Brand may repost content on their official channels with credit.',
      'campaign_usage_2':
          'Paid media whitelisting requires separate written approval.',

      // Agreement / Snackbar
      'campaign_agreement_required': 'Agreement required',
      'campaign_agreement_required_desc': 'Please accept the terms to continue',

      'campaign_agree_prefix': 'You accept the ',
      'campaign_agree_ula': 'user license agreement',
      'campaign_agree_mid': ' &\n',
      'campaign_agree_terms': 'Terms and condition',
      'campaign_agree_suffix': ' of our app.',

      // Withdrawal dialog
      'campaign_withdraw_sent': 'Withdrawal Request Sent',
      'campaign_withdraw_msg':
          'We will review your request soon.\nIt may take up to 1-2 business days',

      // Milestone statuses
      'ms_paid': 'Paid',
      'ms_partial_paid': 'Partial Paid',
      'ms_in_review': 'In Review',
      'ms_declined': 'Declined',
      'ms_todo': 'To Do',

      "earnings_tab_earnings": "Earnings",
      "earnings_tab_transactions": "Transactions",
      "earnings_inner_client_list": "Client List",
      "earnings_inner_platform": "Platform",

      "earnings_total_earnings": "Total Earnings",
      "earnings_recent_earnings": "Recent Earnings",
      "earnings_most_used_platform": "Most Used Platform",

      "earnings_search_client_hint": "Search Client",
      "earnings_search_transactions_hint":
          "Search By Campaign Name, Client Name",

      "earnings_client_header": "Client",
      "earnings_jobs_completed": "Jobs Completed",

      "earnings_recent_transactions_title": "Recent Transactions",
      "earnings_showing_results": "Showing @shown Of @total Results",

      "earnings_no_clients_found": "No clients found",
      "earnings_no_transactions_found": "No transactions found",

      "earnings_add_social_link": "+ ADD SOCIAL LINK",
      "earnings_view_campaign_details": "View Campaign Details",
      "earnings_payment_for": "Payment For “@name”",
      "earnings_withdrawal_request": "Withdrawal Request",

      "earnings_legend_thousands": "Earnings in Thousands",

      "common_low_to_high": "Low To High",
      "common_page": "Page",
      "common_of_n": "Of @n",
      "common_next": "Next",

      "7_days": "7 Days",

      "top_influencer": "Top influencer worked with",

      "create_campaign_welcome": "Welcome, User!",
      "create_campaign_dashboard": "Dashboard",

      "create_campaign_step": "Step",
      "create_campaign_of": "Of",

      "create_campaign_get_started_title": "Let’s Get Started",
      "create_campaign_get_started_subtitle":
          "Set Up The Basics For Your New Campaign",

      "create_campaign_name_label": "Campaign Name",
      "create_campaign_name_hint": "Enter Campaign Name",

      "create_campaign_type_label": "Campaign Type",
      "create_campaign_type_paid_title": "Paid Ad",
      "create_campaign_type_paid_sub": "Launch Targeted Advertising Campaign",
      "create_campaign_type_influencer_title": "Influencer Promotion",
      "create_campaign_type_influencer_sub":
          "Partner With Influencer For Promotion",

      "create_campaign_error_title": "Missing info",
      "create_campaign_error_msg":
          "Please enter campaign name and select a campaign type.",

      "common_previous": "Previous",
      'nav_campaign': 'Campaign',
      'nav_analytics': 'Analytics',
      'nav_explore': 'Explore',

      'create_campaign_step2_title': 'Your Preferences',
      'create_campaign_step2_subtitle':
          'Provide your preferences for this campaign',
      'create_campaign_save_draft': 'Save As Draft',
      'create_campaign_product_type_label': 'Select Product Type',
      'create_campaign_product_type_hint': 'Select Product Type',
      'create_campaign_niche_label': 'Campaign Niche',
      'create_campaign_niche_hint': 'Select Campaign Niches',
      'create_campaign_preferred_influencers_label': 'Preferred Influencers',
      'create_campaign_not_preferred_influencers_label': 'Not preferrable Influencers',
      'create_campaign_preferred_influencers_hint': 'Enter influencers names...(separate each with a comma)'
          'Enter influencer names... (separate with a comma)',
      'create_campaign_not_preferred_influencers_label':
          'Not Preferable Influencers',
      'create_campaign_not_preferred_influencers_hint':
          'Enter influencer names... (separate with a comma)',
      'create_campaign_chip_empty': 'No items added yet',
      'create_campaign_draft_title': 'Draft Saved',
      'create_campaign_draft_msg': 'Your campaign draft has been saved.',
      'create_campaign_error_step2_msg':
          'Please select product type and niche.',
      'common_done': 'Done',

      'create_campaign_step2_missing_type':
          'Please select campaign type first.',
      'create_campaign_recommended_agencies_label': 'Recommended Ad Agencies',
      'create_campaign_other_agencies_label': 'Other Ad Agencies',

      "create_campaign_step3_title": "Campaign Details",
      "create_campaign_step3_subtitle":
          "Describe the requirements and provide a detailed brief.",

      "create_campaign_goals_label": "Campaign Goals",
      "create_campaign_goals_hint":
          "Enter brief description about your campaign goals",

      "create_campaign_product_service_label": "Product/Service Details",
      "create_campaign_product_service_hint":
          "Enter brief description about your product/service details",

      "create_campaign_dos_donts_label": "Do’s & Don’t",
      "create_campaign_dos_label": "Do’s",
      "create_campaign_dos_hint":
          "Example:\n• Show authentic usage, mention eco-friendly aspects\n• Tag @StyleCo in all posts\n• Show products in natural lighting\n• Include discount code in captions",
      "create_campaign_donts_label": "Don’ts",
      "create_campaign_donts_hint":
          "Example:\n• Don’t mention competitor brands\n• Don’t use harsh lighting\n• Don’t mislead about product benefits",

      "create_campaign_terms_label": "Terms & Conditions",

      "create_campaign_reporting_requirements_label": "Reporting Requirements",
      "create_campaign_reporting_requirements_hint":
          "Enter reporting requirements in details",

      "create_campaign_usage_rights_label": "Usage Rights",
      "create_campaign_usage_rights_hint": "Enter usage rights in details",

      "create_campaign_start_date_label": "Starting Date",
      "create_campaign_start_date_hint": "Select start date",

      "create_campaign_duration_label": "Duration",
      "create_campaign_duration_hint": "5 Days",

      "create_campaign_step4_title": "Placement & Budget",
      "create_campaign_step4_subtitle":
          "Provide Your Budget And Set Milestones With Placements",
      "create_campaign_step4_suggestions": "Suggestions",
      "create_campaign_step4_enter_budget": "Enter Budget Amount",
      "create_campaign_step4_min": "Min",
      "create_campaign_step4_quote": "Quote (Budget Breakdown)",
      "create_campaign_step4_base": "Base Campaign Budget",
      "create_campaign_step4_vat": "+ VAT/Tax ({p}%)",
      "create_campaign_step4_total": "Budget Including Tax",
      "create_campaign_step4_net_payable":
          "Net Payable Budget Amount (Inc. Tax)",
      "create_campaign_step4_milestones": "Campaign Milestones",
      "create_campaign_step4_add_milestone": "+ Add Another Milestone",
      "create_campaign_step4_milestone_title_hint":
          "Ex: Initial Content Creation",
      "create_campaign_step4_milestone_platform_hint": "Select Platform",
      "create_campaign_step4_milestone_deliverable_hint":
          "1 Sponsored Video / 1 Post",
      "create_campaign_step4_milestone_day_hint": "DAY 1",
      "create_campaign_step4_promo_target": "Promotion Target",
      "create_campaign_step4_reach": "Reach",
      "create_campaign_step4_views": "Views",
      "create_campaign_step4_likes": "Likes",
      "create_campaign_step4_comments": "Comments",
      "create_campaign_step4_milestone_error":
          "Please fill all milestone fields.",
      "create_campaign_milestone_platform": "Platform",
      "create_campaign_milestone_day": "Day",
      "create_campaign_step5_title": "Upload Your Content",
      "create_campaign_step5_subtitle":
          "Upload Your Campaign Contents For The Influencers",
      "create_campaign_content_assets": "Content Assets",
      "create_campaign_upload_another_asset": "Upload Another Asset",

      "create_campaign_need_sample_title": "Do You Need To Send Sample?",
      "create_campaign_need_sample_label": "Need To Send Sample",
      "create_campaign_confirm_sample_guidelines": "Confirm you've read ",
      "create_campaign_confirm_sample_guidelines1": " Sample Sending Guidelines",

      "create_campaign_brand_assets": "Brand Assets",
      "create_campaign_add_brand_asset": "Add Another Brand Asset",

      "create_campaign_asset_name_hint": "Asset name (e.g. Brand Logo Pack)",
      "create_campaign_asset_meta_hint": "Meta (e.g. PNG, SVG - 2.4 MB)",
      "create_campaign_asset_error": "Please enter asset name and meta.",

      "create_campaign_brand_asset_name_hint":
          "Asset name (e.g. Facebook Page)",
      "create_campaign_brand_asset_value_hint": "Page Link",
      "create_campaign_brand_asset_error": "Please enter brand asset name.",
      "create_campaign_pick_file": "Choose File",
      "create_campaign_picking_file": "Picking...",
      "create_campaign_no_file_selected": "No file selected yet.",

      "create_campaign_step6_title": "Review Your Campaign",
      "create_campaign_step6_subtitle":
          "Get a quick recap for your promotional campaign",
      "create_campaign_step6_campaign_details": "Campaign Details",
      "create_campaign_step6_summer_fashion_campaign": "Summer Fashion Campaign",
      "create_campaign_step6_campaign_title_fallback": "Untitled Campaign",
      "create_campaign_step6_deadline": "Deadline",
      "create_campaign_step6_including_vat": "Including VAT/Tax ({vat})",

      "create_campaign_step6_campaign_brief": "Campaign Brief",
      "create_campaign_step6_campaign_milestones": "Campaign Milestones",
      "create_campaign_step6_content_assets": "Content Assets",
      "create_campaign_step6_terms_conditions": "Terms & Conditions",
      "create_campaign_step6_brand_assets": "Brand Assets",

      "create_campaign_step6_campaign_goals": "Campaign Goals",
      "create_campaign_step6_product_service": "Product/Service Details",
      "create_campaign_step6_content_requirements": "Content Requirements",
      "create_campaign_step6_dos_donts": "Do’s & Don’ts",
      "create_campaign_step6_dos": "Do’s",
      "create_campaign_step6_donts": "Don’ts",

      "create_campaign_step6_total_budget": "Total Campaign Budget",
      "create_campaign_step6_budget_including_vat":
          "+ Including VAT/Tax ({vat})",

      "create_campaign_step6_reporting_requirements": "Reporting Requirements",
      "create_campaign_step6_usage_rights": "Usage Rights",

      "create_campaign_step6_get_quote": "Get Quote",
      "create_campaign_step6_submit_title": "Submitted",
      "create_campaign_step6_submit_msg": "Your campaign has been submitted successfully.",

      'create_campaign_step6_popup_title': 'Campaign Placement Confirmed',
      'create_campaign_step6_popup_message': 'We will review your campaign soon.\nIt may take up to 3–5 business days.',

      'brand_campaign_details_welcome': 'Welcome, User!',
      'brand_campaign_details_campaign_details': 'Campaign Details',
      'brand_campaign_details_influencers': 'Influencers',
      'brand_campaign_details_platforms': 'Platforms',
      'brand_campaign_details_deadline': 'Deadline',
      'brand_campaign_details_days_remaining': 'Days Remaining',
      'brand_campaign_details_budget_pending': 'Budget Pending',

      'brand_campaign_details_campaign_progress': 'Campaign Progress',
      'brand_campaign_details_submitted': 'Submitted',
      'brand_campaign_details_submitted_sub': 'Campaign Request Sent',
      'brand_campaign_details_quoted': 'Quoted',
      'brand_campaign_details_quoted_sub': 'Quote Provided',
      'brand_campaign_details_paid': 'Paid',
      'brand_campaign_details_paid_sub': 'Payment Processed',
      'brand_campaign_details_promoting': 'Promoting',
      'brand_campaign_details_promoting_sub': 'Content is Live',
      'brand_campaign_details_completed': 'Completed',
      'brand_campaign_details_completed_sub': 'Campaign Finished',

      'brand_campaign_details_quote_details': 'Quote Details',
      'brand_campaign_details_base_campaign_budget': 'Base Campaign Budget',
      'brand_campaign_details_vat_tax': 'VAT/Tax (15%)',
      'brand_campaign_details_total_campaign_cost': 'Total Campaign Cost',
      'brand_campaign_details_request_quote': 'Request',
      'brand_campaign_details_accept_quote': 'Accept Quote',
      'brand_campaign_details_quote': 'Quote',
      'brand_campaign_details_request_quote_msg': 'Request sent.',
      'brand_campaign_details_accept_quote_msg': 'Quote accepted.',

      'brand_campaign_details_campaign_milestones': 'Campaign Milestones',
      'brand_campaign_details_campaign_not_started': 'Campaign Not Started',
      'brand_campaign_details_progress': 'Progress',
      'brand_campaign_details_of': 'of',
      'brand_campaign_details_completed_small': 'Completed',
      'brand_campaign_details_pending': 'Pending',

      'brand_campaign_details_provide_rating': 'Provide Rating To Influencers',
      'brand_campaign_details_campaign_brief': 'Campaign Brief',
      'brand_campaign_details_campaign_goals': 'Campaign Goals',
      'brand_campaign_details_product_service': 'Product/Service Details',
      'brand_campaign_details_content_requirements': 'Content Requirements',
      'brand_campaign_details_dos_donts': "Do's & Don'ts",
      'brand_campaign_details_dos': "Do's",
      'brand_campaign_details_donts': "Don'ts",

      'brand_campaign_details_content_assets': 'Content Assets',
      'brand_campaign_details_upload_another_asset': 'Upload Another Asset',
      'brand_campaign_details_assets': 'Assets',
      'brand_campaign_details_download_msg': 'Download started.',
      'brand_campaign_details_upload_msg': 'Upload flow coming soon.',

      'brand_campaign_details_terms_conditions': 'Terms & Conditions',
      'brand_campaign_details_reporting_requirements': 'Reporting Requirements',
      'brand_campaign_details_usage_rights': 'Usage Rights',

      'brand_campaign_details_requote': 'Requote',

      'brand_campaign_requote_title': 'Requote',
      'brand_campaign_requote_subtitle': 'Requote your campaign budget',
      'brand_campaign_requote_overview': 'New Requote Overview',
      'brand_campaign_requote_base': 'Base Campaign Budget',
      'brand_campaign_requote_vat': 'VAT/Tax (15%)',
      'brand_campaign_requote_total': 'Total Campaign Cost',
      'brand_campaign_requote_submit': 'Requote To Admin',
      'brand_campaign_requote_invalid': 'Please enter a valid budget.',
      'brand_campaign_requote_sent': 'Requote request sent to admin.',

      'brand_campaign_fund_title': 'Fund Your Campaign',
      'brand_campaign_fund_total_due': 'Total Due',
      'brand_campaign_fund_minimum_label':
          'Minimum Fund Needed To Start The Campaign (50%)',
      'brand_campaign_fund_full': 'Pay In Full (100%)',
      'brand_campaign_fund_min': 'Pay Minimum (50%)',
      'brand_campaign_fund_75': 'Pay (75%)',
      'brand_campaign_fund_method': 'Payment Method',
      'brand_campaign_fund_card': 'Credit / Debit Card',
      'brand_campaign_fund_bkash': 'bKash',
      'brand_campaign_pay_now': 'Pay Now',
      'brand_campaign_payment': 'Payment',
      'brand_campaign_payment_success': 'Payment initiated.',
      'brand_campaign_payment_invalid':
          'Amount must be between minimum and total due.',
    },

    // Bangla
    'bn_BD': {
      'onb1_title': 'সেরা ট্যালেন্ট ও ব্র্যান্ডের \nসাথে যুক্ত হোন',
      'onb1_body':
          'ভেরিফাইড এজেন্সি ও ইনফ্লুয়েন্সারদের সাথে আপনার স্বপ্নের ব্র্যান্ডকে যুক্ত করার সেরা প্ল্যাটফর্ম এটি।',
      'onb2_title': 'নিরাপদ পেমেন্ট ও\nমাইলস্টোন',
      'onb2_body':
          'সহজেই ক্যাম্পেইন পরিচালনা করুন। কাজ শেষ হওয়ার পরই আপনার ফান্ড নিরাপদে ছাড়া হবে।',
      'onb3_title': 'আপনার সম্ভাবনাকে \nবাস্তবে রূপ দিন',
      'onb3_body':
          'আপনার পণ্য লঞ্চ করুন বা নিজের ব্যক্তিগত ব্র্যান্ড তৈরি করুন ব্রান্ডগুরু এর সাথে আপনার গ্রোথ হবে দ্রুততম!',
      'btn_next': 'পরবর্তী',
      'btn_get_started': 'শুরু করুন',
      'btn_skip': 'স্কিপ',

      // Login
      'login_title': 'লগইন',
      'login_subtitle': 'আপনাকে স্বাগতম',
      'login_phone_hint': 'ফোন নাম্বার',
      'login_password_hint': 'পাসওয়ার্ড',
      'login_forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'login_button': 'লগইন',
      'login_no_account': 'অ্যাকাউন্ট নেই?',
      'login_sign_up': 'সাইন আপ করুন',

      // Signup (account type)
      'signup_title': 'সাইন আপ',
      'signup_subtitle': 'আপনার অ্যাকাউন্ট টাইপ নির্বাচন করুন',
      'signup_brand_title': 'ব্র্যান্ড',
      'signup_brand_subtitle': 'আমার ব্যবসা প্রচার করব',
      'signup_influencer_title': 'ইনফ্লুয়েন্সার',
      'signup_influencer_subtitle': 'আমার রিচ থেকে আয় করব',
      'signup_agency_title': 'অ্যাড এজেন্সি',
      'signup_agency_subtitle': 'ক্লায়েন্ট ক্যাম্পেইন ম্যানেজ করব',
      'signup_continue': 'কন্টিনিউ',

      'infl_profile_title': 'হ্যালো, ইনফ্লুয়েন্সার!',
      'brand_profile_title': 'ব্র্যান্ড প্রোমোশনের জন্য প্রস্তুত?',
      'agency_profile_title': 'Hello, Agency!',
      'infl_profile_subtitle': 'চলুন, আপনার প্রোফাইল তৈরি করা যাক',
      'brand_profile_subtitle': 'আপনার ব্র্যান্ডের প্রচার শুরু করুন!',
      'infl_profile_section_title': 'প্রোফাইল বিবরণী',
      'brand_name_label': 'ব্রান্ডের নাম *',
      'brand_name_hint': 'আপনার বিজনেস অথবা ব্র্যান্ডের পূর্ণ নাম লিখুন',
      'infl_first_name_label': 'নামের প্রথমাংশ *',
      'infl_first_name_hint': 'আপনার নামের প্রথমাংশ দিন',
      'infl_last_name_label': 'নামের শেষাংশ *',
      'infl_last_name_hint': 'আপনার নামের শেষাংশ দিন',
      'infl_email_label': 'ইমেইল অ্যাড্রেস *',
      'infl_email_hint': 'Ex: johndoe@email.com',
      'infl_phone_label': 'ফোন নম্বর *',
      'infl_phone_hint': 'Ex: +8801234567890',

      'btn_continue': 'এগিয়ে যান',
      'auth_already_have_account': 'অ্যাকাউন্ট আছে?',
      'auth_login': 'লগইন করুন',

      // ✅ OTP / Verification page
      'otp_title': 'ভেরিফিকেশন কোড পাঠানো হয়েছে',
      'otp_subtitle': 'আমরা ভেরিফিকেশন কোড পাঠিয়েছি এই নম্বরে @phone',
      'otp_didnt_receive': 'কোড পাননি ?',
      'otp_resend': 'পুনরায় চেষ্টা করুন',
      'otp_continue': 'এগিয়ে যান',
      'otp_have_account': 'অ্যাকাউন্ট আছে?',
      'otp_login': 'লগইন করুন',

      // Phone verified page
      'phone_verified_title': 'ফোন নম্বর\nভেরিফাইড হয়েছে',
      'phone_verified_body':
          'দারুণ! আপনার ফোন নম্বরটি আপনার অ্যাকাউন্ট এর সাথে যুক্ত হয়েছে। পরবর্তী ধাপগুলোতে এগিয়ে চলুন।',

      'influ_addr_title': 'হ্যালো, পার্টনার!',
      'agency_addr_title': 'হ্যালো, পার্টনার!',
      'brand_addr_title': 'হ্যালো, পার্টনার!',
      'brand_addr_subtitle': 'সোশ্যাল মিডিয়ায় আপনার উপস্থিতি জানান দিন।',
      'agency_addr_subtitle': 'সোশ্যাল মিডিয়ায় আপনার উপস্থিতি জানান দিন।',
      'brand_addr_body':
          'ইনফ্লুয়েন্সাররা যাতে আপনার ব্র্যান্ডের ধরণ ও রুচি (Aesthetic) বুঝতে পারে, সেজন্য আপনার অ্যাক্টিভ সোশ্যাল চ্যানেলগুলো যুক্ত করুন।',
      'agency_addr_body':
          'ইনফ্লুয়েন্সাররা যাতে আপনার ব্র্যান্ডের ধরণ ও রুচি (Aesthetic) বুঝতে পারে, সেজন্য আপনার অ্যাক্টিভ সোশ্যাল চ্যানেলগুলো যুক্ত করুন।',
      'influ_addr_subtitle': 'গিফট বা প্রোডাক্ট আমরা কোথায় পাঠাবো?',
      'influ_addr_body':
          'সেরা ব্র্যান্ডগুলো রিভিউয়ের জন্য আপনার কাছে প্রোডাক্ট পাঠাতে চায়। তাই সঠিক ঠিকানাটি দিন যাতে তারা সহজেই আপনার কাছে পৌঁছাতে পারে!',
      'influ_addr_info':
          'লোকেশন নিয়ে টেনশন নেই! কাজের প্রয়োজন অনুযায়ী আপনি যখন খুশি ডেলিভারি ঠিকানা পরিবর্তন করতে পারবেন।',
      'influ_addr_section_title': 'আপনার ঠিকানা',
      'influ_addr_thana_label': 'থানা *',
      'influ_addr_thana_hint': 'আপনার থানা সিলেক্ট করুন',
      'influ_addr_zilla_label': 'জেলা *',
      'influ_addr_zilla_hint': 'আপনার জেলা সিলেক্ট করুন',
      'influ_addr_full_label': 'বিস্তারিত ঠিকানা *',
      'influ_addr_full_hint': 'আপনার পূর্ণ ঠিকানা লিখুন (বাড়ি নং, রোড নং)',
      'influ_addr_full_error': 'দয়া করে আপনার পূর্ণ ঠিকানা লিখুন',
      'influ_addr_select_error': 'দয়া করে একটি অপশন সিলেক্ট করুন',
      'influ_addr_thana_sheet_title': 'থানা সিলেক্ট করুন',
      'influ_addr_zilla_sheet_title': 'জেলা সিলেক্ট করুন',

      'influ_social_title': 'আপনার প্রতিভা দেখান!',
      'influ_social_subtitle': 'আপনার সোশ্যাল মিডিয়া প্রোফাইলগুলো যুক্ত করুন।',
      'influ_social_body':
          'এটাই আপনার ডিজিটাল সিভি। যত বেশি প্রোফাইল লিংক করবেন, তত বেশি ক্যাম্পেইন পাওয়ার সুযোগ।',
      'influ_social_info':
          'আপনার অডিয়েন্স যাচাই করতে এবং সেরা পেইড কোলাবোরেশন বা স্পনসরশিপ খুঁজে দিতে এটি আমাদের সাহায্য করবে।',
      'influ_social_section_title': 'আপনার সোশ্যাল মিডিয়া লিংকসমূহ',
      'influ_social_website_label': 'ওয়েব অ্যাড্রেস (যদি থাকে)',
      'influ_social_website_hint': 'ওয়েব অ্যাড্রেস',
      'influ_social_platform_label': 'প্ল্যাটফর্ম বাছাই করুন *',
      'influ_social_platform_hint': 'একটি প্ল্যাটফর্ম সিলেক্ট করুন',
      'influ_social_platform_error': 'অনুগ্রহ করে একটি প্ল্যাটফর্ম বাছাই করুন',
      'influ_social_profile_label': 'প্রোফাইল লিংক *',
      'influ_social_profile_hint': 'প্রোফাইল লিংক',
      'influ_social_profile_error': 'অনুগ্রহ করে প্রোফাইল লিংক লিখুন',
      'influ_social_add_another': '+ আর যুক্ত করুন',

      'influ_kyc_title': 'পেমেন্ট আনলক করুন!',
      'influ_kyc_subtitle': 'উপার্জন শুরু করুন!',
      'influ_kyc_body':
          'সঠিক মানুষকে পেমেন্ট পৌঁছানো নিশ্চিত করতে এটি একটি সিকিউরিটি চেক। আপনার তথ্য আমাদের কাছে সম্পূর্ণ নিরাপদ।',
      'influ_kyc_info':
          'প্রতারণা রোধ করতে এবং অ্যাকাউন্টের নিরাপত্তা বজায় রাখতে আমরা এই তথ্য যাচাই করি। বিস্তারিত জানতে আমাদের প্রাইভেসি পলিসি দেখুন।',
      'influ_kyc_section_title': 'জাতীয় পরিচয়পত্র যাচাই',
      'influ_kyc_nid_label': 'আপনার এনআইডি (NID) নম্বর *',
      'influ_kyc_nid_hint': 'জাতীয় পরিচয়পত্র নম্বর লিখুন',
      'influ_kyc_nid_error': 'অনুগ্রহ করে আপনার এনআইডি নম্বর লিখুন',
      'influ_kyc_front_label': 'এনআইডি-র সামনের ছবি',
      'influ_kyc_back_label': 'এনআইডি-র পেছনের ছবি',
      'influ_kyc_upload_helper': 'PNG, JPEG, PDF (Max 2MB)',
      'influ_kyc_skip': 'স্কিপ',
      'influ_kyc_submit': 'সাবমিট করুন',

      'influ_success_title': 'অভিনন্দন!',
      'influ_success_subtitle': 'আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে!',
      'influ_success_body':
          'আপনার তথ্যগুলো আমাদের কাছে নিরাপদে পৌঁছেছে। ভেরিফিকেশন সম্পূর্ণ করতে আমাদের টিম এখন সেগুলো পর্যালোচনা করবে।',
      'influ_success_hint':
          'এতে সাধারণত ২৪ থেকে ৪৮ ঘণ্টা সময় লাগতে পারে। অ্যাকাউন্ট ভেরিফাই হলেই আমরা আপনাকে নোটিফিকেশন ও ইমেইল দিয়ে জানাবো। এর মধ্যে আপনি চাইলে ড্যাশবোর্ড ঘুরে দেখতে পারেন এবং প্রোফাইল আপডেট করতে পারেন।',
      'influ_success_btn': 'ড্যাশবোর্ড দেখুন',

      // Brand signup – step 1
      'brand_step1_title': 'ব্র্যান্ড প্রোমোশনের জন্য প্রস্তুত?',
      'brand_step1_subtitle': 'আপনার ব্র্যান্ডের প্রচার শুরু করুন!',
      'brand_step1_section_title': 'জরুরি তথ্যাবলী',

      'brand_step1_brand_label': 'ব্র্যান্ডের নাম *',
      'brand_step1_brand_hint': 'আপনার বিজনেস অথবা ব্র্যান্ডের পূর্ণ নাম লিখুন',
      'brand_step1_brand_error': 'ব্র্যান্ডের নাম লিখুন',

      'brand_step1_first_label': 'নামের প্রথমাংশ *',
      'brand_step1_first_hint': 'আপনার নামের প্রথমাংশ দিন',
      'brand_step1_first_error': 'নামের প্রথমাংশ লিখুন',

      'brand_step1_last_label': 'নামের শেষাংশ *',
      'brand_step1_last_hint': 'আপনার নামের শেষাংশ দিন',
      'brand_step1_last_error': 'নামের শেষাংশ লিখুন',

      'brand_step1_email_label': 'ইমেইল অ্যাড্রেস *',
      'brand_step1_email_hint': 'উদাহরণ: johndoe@email.com',
      'brand_step1_email_error': 'ইমেইল অ্যাড্রেস লিখুন',
      'brand_step1_email_invalid': 'সঠিক ইমেইল অ্যাড্রেস লিখুন',

      'brand_step1_phone_label': 'ফোন নম্বর *',
      'brand_step1_phone_hint': 'উদাহরণ: +8801234567890',
      'brand_step1_phone_error': 'ফোন নম্বর লিখুন',

      'brand_step1_lang_en': 'English',
      'brand_step1_lang_bn': 'বাংলা',

      'brand_step1_footer_title': 'অ্যাকাউন্ট আছে?',
      'brand_step1_footer_login': 'লগইন করুন',

      'brand_tl_title': 'ব্যবসাটিকে অফিসিয়াল করুন!',
      'brand_tl_subtitle': 'নিবন্ধিত অংশীদার হন',
      'brand_tl_body':
          'ট্রেড লাইসেন্স আপলোড করার মাধ্যমে আপনি আপনার ব্যবসার বৈধতা ও পেশাগত দক্ষতা প্রমাণ করছেন, যা আপনাকে সেরা ট্যালেন্টদের সঙ্গে যুক্ত হতে সাহায্য করবে।',
      'brand_tl_info':
          'সকল আর্থিক লেনদেন নিরাপদ রাখতে এই যাচাইকরণ আবশ্যক। আপনার ডকুমেন্ট শুধুমাত্র ভেরিফিকেশনের জন্যই ব্যবহার হবে। বিস্তারিত জানতে প্রাইভেসি পলিসি দেখুন।',
      'brand_tl_section_title': 'আপনার ট্রেড লাইসেন্স দিন',
      'brand_tl_number_label': 'আপনার ট্রেড লাইসেন্স নম্বর *',
      'brand_tl_number_hint': 'ট্রেড লাইসেন্স নম্বরটি লিখুন',
      'brand_tl_number_error': 'ট্রেড লাইসেন্স নম্বর প্রদান করুন',
      'brand_tl_upload_label': 'Upload Trade License',
      'brand_tl_upload_helper': 'PNG, JPEG, PDF (Max 2MB)',
      'brand_tl_skip': 'স্কিপ',
      'brand_tl_continue': 'এগিয়ে যান',

      'brand_tin_title': 'আর মাত্র একটি ধাপ!',
      'brand_tin_subtitle': 'ফিনান্সিয়াল সেটআপ সম্পূর্ণ করুন।',
      'brand_tin_body':
          'প্ল্যাটফর্মে নিরাপদ পেমেন্ট এবং ইনভয়েস জেনারেট করার জন্য আপনার ব্যবসায়িক ট্যাক্স ইনফরমেশন প্রয়োজন। তাই দয়া করে অফিসিয়াল ট্যাক্স ও আইডেন্টিফিকেশন নম্বর দিন।',
      'brand_tin_info':
          'আপনার তথ্য সম্পূর্ণ সুরক্ষিত ও এনক্রিপ্টেড। বিস্তারিত জানতে আমাদের প্রাইভেসি পলিসি দেখুন।',
      'brand_tin_section_title': 'আপনার TIN তথ্য প্রদান করুন',
      'brand_tin_tin_label': 'আপনার TIN নম্বর *',
      'brand_tin_tin_hint': 'আপনার TIN নম্বর লিখুন',
      'brand_tin_tin_error': 'অনুগ্রহ করে আপনার TIN নম্বর লিখুন',
      'brand_tin_upload_label': 'TIN সার্টিফিকেট আপলোড করুন',
      'brand_tin_upload_helper': 'PNG, JPEG, PDF (সর্বোচ্চ 2MB)',
      'brand_tin_bin_label': 'আপনার BIN নম্বর (ঐচ্ছিক)',
      'brand_tin_bin_hint': 'আপনার BIN নম্বর লিখুন',
      'brand_tin_skip': 'স্কিপ',
      'brand_tin_continue': 'এগিয়ে যান',

      'fp_title': 'পাসওয়ার্ড\nভুলে গেছেন?',
      'fp_subtitle':
          'চিন্তার কিছু নেই! আমরা আপনাকে\nপাসওয়ার্ড রিসেট করার নিয়ম পাঠিয়ে দেব।',
      'fp_input_hint': 'ফোন / ইমেইল',
      'fp_continue': 'এগিয়ে যান',
      'fp_login_question': 'অ্যাকাউন্ট আছে?',
      'fp_login': 'লগইন করুন',

      'fp_verify_title': 'ভেরিফিকেশন কোড\nপাঠানো হয়েছে',
      'fp_verify_subtitle': 'আমরা ভেরিফিকেশন কোড পাঠিয়েছি এই নম্বরে @phone',
      'fp_resend': 'কোড পাননি ? পুনরায় চেষ্টা করুন',
      'fp_otp_continue': 'এগিয়ে যান',

      'fp_new_title': 'নতুন পাসওয়ার্ড দিন',
      'fp_new_subtitle': 'কমপক্ষে ৮ অক্ষর বা তার বেশি হতে হবে',
      'fp_new_password_hint': 'নতুন পাসওয়ার্ড লিখুন',
      'fp_confirm_password_hint': 'নতুন পাসওয়ার্ড নিশ্চিত করুন',
      'fp_reset_button': 'পাসওয়ার্ড রিসেট করুন',

      'fp_success_title': 'পরিবর্তন সফল',
      'fp_success_subtitle': 'আপনার পাসওয়ার্ড সফলভাবে পরিবর্তিত হয়েছে',
      'fp_success_button': 'ড্যাশবোর্ডে ফিরে যান',

      'home_locked_hero_title': 'আর মাত্র কয়েক ধাপ!',
      'home_locked_hero_subtitle':
          'আপনার সম্পূর্ণ ড্যাশবোর্ড, আয় এবং নতুন কাজের সুযোগগুলো আনলক করতে ভেরিফিকেশন সম্পন্ন করুন!',

      'home_locked_verification_title': 'ভেরিফিকেশনের অবস্থা',
      'home_locked_profile_title': 'প্রোফাইল সম্পূর্ণ করুন',
      'home_locked_need_help': 'সাহায্য প্রয়োজন?',
      'home_locked_help_guide': 'ভেরিফিকেশন গাইড',
      'home_locked_help_support': 'সাপোর্ট টিমের সাথে যোগাযোগ করুন',

      'home_locked_basic_info_title': 'প্রাথমিক তথ্য',
      'home_locked_basic_info_sub':
          'আপনার সাথে যোগাযোগ করতে এই তথ্যগুলো ব্যবহার করা হবে',
      'home_locked_social_portfolio_title': 'সোশ্যাল পোর্টফোলিও',
      'home_locked_social_portfolio_sub':
          '১টি যুক্ত আছে, চাইলে আরও যোগ করতে পারবেন',
      'home_locked_nid_title': 'জাতীয় পরিচয়পত্র (NID)',
      'home_locked_nid_sub': 'রিভিউ চলছে',
      'home_locked_trade_license_title': 'ট্রেড লাইসেন্স',
      'home_locked_trade_license_sub':
          'বাতিল হয়েছে, দেওয়া ডকুমেন্টের তথ্য প্রোফাইলের তথ্যের সাথে মিলেনি',
      'home_locked_tin_title': 'টিআইএন (TIN)',
      'home_locked_bin_title': 'বিআইএন (BIN)',
      'home_locked_payment_title': 'পেমেন্ট সেটআপ',
      'home_locked_verify_email_title': 'ইমেইল ভেরিফাই করুন',
      'home_locked_generic_pending': 'অপেক্ষমাণ',

      'home_locked_profile_picture_title': 'প্রোফাইল ছবি যোগ করুন',
      'home_locked_profile_picture_sub': 'ক্লায়েন্টরা আপনাকে সহজে চিনতে পারবে',
      'home_locked_add_niches_title': 'কাজের ধরন বা নিস (Niche) যোগ করুন',
      'home_locked_add_skills_title': 'দক্ষতা বা স্কিল যোগ করুন',
      'home_locked_add_bio_title': 'বায়ো (Bio) লিখুন',

      'home_locked_help_niche':
          'নিস হচ্ছে কোনও নির্দিষ্ট আগ্রহ, চাহিদা বা নির্দিষ্ট ধরনের দর্শক — যেখানে একজন ইনফ্লুয়েন্সার বা এজেন্সি মূলত কাজ করে।',
      'home_locked_help_skills':
          'একটি সফল এজেন্সি গড়ে তুলতে সৃজনশীল, প্রযুক্তিগত, যোগাযোগ দক্ষতা এবং ব্যবসায়িক দক্ষতার সঠিক মিশ্রণ দরকার।',
      'support_contact_title': 'সাপোর্ট টিম',
      'support_helpline_section_title': 'হেল্পলাইন নম্বরসমূহ',
      'support_email_section_title': 'ইমেইল করুন',
      'support_help_line_1': 'Help Line 1',
      'support_help_line_2': 'Help Line 2',
      'support_help_line_3': 'Help Line 3',
      'support_time_10_8': 'সকাল ১০টা – রাত ৮টা',

      // Earnings overview (card)
      'earnings_overview': 'ইনকামের সংক্ষিপ্ত বিবরণ',
      'lifetime_earnings': 'মোট ইনকাম',
      'pending_earnings': 'প্রক্রিয়াধীন ইনকাম',

      // Summary row
      'home_active_jobs': 'চলমান কাজ',
      'home_new_offers_for_you': 'নতুন কাজের অফার',
      'home_view_all': 'সব দেখুন',

      // Work in progress
      'home_work_in_progress': 'চলমান কাজ',
      'home_active_suffix': 'টি চলমান',
      'home_view_all_jobs': 'সব কাজ দেখুন →',
      'home_budget': 'বাজেট',
      'home_complete_suffix': 'সম্পন্ন',
      'home_view': 'ভিউ',

      // Lifetime summary
      'home_lifetime_summary': 'আজীবন কাজের সংক্ষিপ্তসার',
      'home_jobs_completed_suffix': 'টি কাজ করেছেন',
      'home_top_client': 'সেরা ক্লায়েন্ট',
      'home_last_job': 'সর্বশেষ কাজ: ১২ Dec ২০২৫',

      'home_total_jobs_completed': 'সফল কাজের সংখ্যা',
      'home_total_earnings': 'মোট ইনকাম',
      'home_total_jobs_declined': 'বাতিলকৃত কাজের সংখ্যা',
      'home_most_used_platform': 'সর্বাধিক ব্যবহৃত প্ল্যাটফর্ম',

      'notifications_title': 'নোটিফিকেশন',
      'notifications_mark_all_read': 'সব পড়া হয়েছে হিসেবে মার্ক করুন',
      'notifications_new': 'নতুন',
      'notifications_earlier': 'পূর্বের',
      'notifications_empty': 'কোন নোটিফিকেশন নেই',

      // Top bar
      'topbar_welcome_user': 'স্বাগতম, User!',
      'topbar_ready_to_earn': 'আজ ইনকামের জন্য প্রস্তুত?',

      // Bottom nav
      'nav_home': 'হোম',
      'nav_jobs': 'কাজ',
      'nav_earnings': 'ইনকাম',
      'nav_profile': 'প্রোফাইল',

      // Common
      'welcome_user': 'স্বাগতম, User!',
      'campaign_details_title': 'ক্যাম্পেইন ডিটেইলস',

      // Shipping page
      'shipping_where_to_send': 'পণ্য কোথায় পাঠানো হবে?',
      'shipping_address_house': 'বাড়ি',
      'shipping_address_office': 'অফিস',
      'shipping_default': 'ডিফল্ট',
      'shipping_add_another': '+ আরেকটি যোগ করুন',
      'shipping_confirm_read_terms':
          'ক্লায়েন্টের শর্তাবলি পড়েছেন তা নিশ্চিত করুন',
      'shipping_accept_license_terms':
          'আপনি আমাদের অ্যাপের ব্যবহার লাইসেন্স ও শর্তাবলি মেনে নিচ্ছেন।',
      'shipping_decline': 'বাতিল করুন',
      'shipping_accept': 'গ্রহণ করুন',

      // address form
      'shipping_address_form_title': 'ঠিকানা',
      'shipping_address_form_set_default': 'ডিফল্ট করুন',
      'shipping_address_form_give_name_label': 'নাম দিন',
      'shipping_address_form_give_name_hint': 'ঠিকানাটির জন্য একটি নাম দিন',
      'shipping_address_form_thana_label': 'থানা *',
      'shipping_address_form_thana_hint': 'থানা নির্বাচন করুন',
      'shipping_address_form_zilla_label': 'জেলা *',
      'shipping_address_form_zilla_hint': 'জেলা নির্বাচন করুন',
      'shipping_address_form_full_label': 'সম্পূর্ণ ঠিকানা *',
      'shipping_address_form_full_hint': 'সম্পূর্ণ ঠিকানা লিখুন',
      'shipping_address_form_save': 'সেভ করুন',
      'shipping_address_form_error_title': 'ঠিকানা',
      'shipping_address_form_error_full_required':
          'দয়া করে সম্পূর্ণ ঠিকানা লিখুন।',
      'shipping_address_custom': 'ঠিকানা',
      'shipping_thana_banani': 'বনানী',
      'shipping_thana_gulshan': 'গুলশান',
      'shipping_thana_dhanmondi': 'ধানমন্ডি',
      'shipping_thana_mirpur': 'মিরপুর',
      'shipping_zilla_dhaka': 'ঢাকা',
      'shipping_zilla_chattogram': 'চট্টগ্রাম',
      'shipping_zilla_sylhet': 'সিলেট',
      'shipping_zilla_rajshahi': 'রাজশাহী',
      'shipping_address_form_error_thana_zilla_required':
          'দয়া করে থানা এবং জেলা দুটোই নির্বাচন করুন।',

      'language_title': 'ভাষা',
      'language_subtitle': 'আপনার পছন্দের ভাষা নির্বাচন করুন',
      'select_language_header': 'ভাষা নির্বাচন করুন',
      'english': 'English',
      'bangla': 'বাংলা',

      'report_log': 'রিপোর্ট লগ',
      'flagged': 'ফ্ল্যাগড',
      'pending': 'পেন্ডিং',
      'resolved': 'রিসলভড',
      'search_hint': 'ক্যাম্পেইন নাম দিয়ে খুঁজুন...',
      'milestone': 'মাইলস্টোন',
      'hours_ago': 'ঘন্টা আগে',
      'date_format': '১৫ ডিসে, ২০২৫',
      'audio_issue': 'অডিও কোয়ালিটি প্রয়োজনীয়তা পূরণ করে না...',

      'home_earnings_overview': 'ইনকামের সংক্ষিপ্ত বিবরণ',
      'home_lifetime_earnings': 'মোট ইনকাম',
      'home_pending_earnings': 'প্রক্রিয়াধীন ইনকাম',
      'home_due_in_days': 'বাকি: @days দিন',
      'home_due_tomorrow': 'বাকি: আগামীকাল',

      // ---------- JOBS ----------
      'jobs_search_hint': 'জব বা ক্লায়েন্টের নাম দিয়ে খুঁজুন',
      'jobs_tab_new_offers': 'নতুন অফার',
      'jobs_tab_active_jobs': 'চলমান কাজ',
      'jobs_tab_active': 'চলমান',
      'jobs_tab_budgeting_quoting': 'বাজেট ও দরপত্র',
      'jobs_tab_draft': 'ড্রাফটস',
      'jobs_tab_canceled': 'বাতিলসমূহ',
      'jobs_tab_completed': 'সম্পন্ন',
      'jobs_tab_pending': 'পেন্ডিং',
      'jobs_tab_declined': 'বাতিল',

      'jobs_header_new_offers': 'নতুন কাজের অফার আপনার জন্য!',
      'jobs_header_active': 'চলমান কাজ',
      'jobs_header_completed': 'সম্পন্ন কাজ',
      'jobs_header_pending': 'পেন্ডিং পেমেন্ট',
      'jobs_header_declined': 'বাতিল কাজ',

      'jobs_filter_low_to_high': 'কম থেকে বেশি',
      'jobs_empty': 'কোনো কাজ পাওয়া যায়নি',

      // ---------- COMMON ----------
      'common_view': 'ভিউ',
      'common_budget': 'বাজেট',
      'common_accept': 'গ্রহণ করুন',
      'common_decline': 'বাতিল করুন',
      'common_complete_suffix': 'সম্পন্ন',
      'common_due_in_days': 'বাকি: @days দিন',
      'common_due_tomorrow': 'বাকি: আগামীকাল',

      // -------- Common --------
      'common_platforms': 'প্ল্যাটফর্ম',
      'common_client': 'ক্লায়েন্ট',
      'common_completed': 'সম্পন্ন',
      'common_no_deadline': 'কোনো সময়সীমা নেই',
      'common_no_jobs_found': 'কোনো কাজ পাওয়া যায়নি',

      // Sort / Search
      'jobs_sort_low_to_high': 'কম থেকে বেশি',

      // Due / Remaining
      'label_due_days': 'বাকি: @days দিন',
      'label_due_tomorrow': 'বাকি: আগামীকাল',
      'label_days_remaining': '@days দিন বাকি',

      // -------- Home --------
      'home_active_badge': '@count টি চলমান',
      'home_jobs_completed_line': '@count টি কাজ করেছেন',
      'home_progress_complete_line': '@percent% সম্পন্ন',

      // -------- Jobs Tabs --------
      'jobs_header_active_jobs': 'চলমান কাজ',
      'jobs_header_completed_jobs': 'সম্পন্ন কাজ',
      'jobs_header_pending_payments': 'পেন্ডিং পেমেন্ট',
      'jobs_header_declined_jobs': 'বাতিল কাজ',

      // -------- Campaign Details --------
      'campaign_your_profit': 'আপনার লাভ (@percent%)',
      'campaign_deadline': 'সময়সীমা',

      'campaign_quote_details': 'কোটের বিস্তারিত',
      'campaign_budget': 'ক্যাম্পেইন বাজেট',
      'campaign_vat_tax': 'ভ্যাট/ট্যাক্স',
      'campaign_total_cost': 'মোট ক্যাম্পেইন খরচ',
      'campaign_request_requote': 'পুনরায় কোট অনুরোধ',

      'campaign_payment_milestones': 'পেমেন্ট মাইলস্টোন',
      'campaign_progress': 'অগ্রগতি',
      'campaign_paid_of_total': '@totalটির মধ্যে @paidটি পরিশোধিত',

      'campaign_total_earnings': 'ক্যাম্পেইন থেকে মোট আয়',
      'campaign_withdrawal_request': 'উত্তোলনের আবেদন',

      'campaign_brief': 'ক্যাম্পেইন ব্রিফ',
      'campaign_content_assets': 'কনটেন্ট অ্যাসেটস',
      'campaign_terms_conditions': 'শর্তাবলী',
      'campaign_brand_assets': 'ব্র্যান্ড অ্যাসেটস',

      // Brief content
      'campaign_goals': 'ক্যাম্পেইন লক্ষ্য',
      'campaign_goals_desc':
          'Gen Z এবং মিলেনিয়াল অডিয়েন্সের জন্য আমাদের নতুন সামার স্কিনকেয়ার লাইন প্রচার করুন। প্রাকৃতিক উপাদান এবং টেকসই প্যাকেজিংয়ে ফোকাস করুন।',
      'campaign_content_requirements': 'কনটেন্ট রিকোয়ারমেন্ট',

      'campaign_req_1':
          'প্রতি প্ল্যাটফর্মে কমপক্ষে ১টি ফিড পোস্ট এবং ২–৩টি স্টোরি।',
      'campaign_req_2':
          'প্রদত্ত ব্র্যান্ড অ্যাসেটস এবং হ্যাশট্যাগ ব্যবহার করুন।',
      'campaign_req_3':
          'প্রতিটি কনটেন্টে অফিসিয়াল ব্র্যান্ড অ্যাকাউন্ট ট্যাগ করুন।',

      'campaign_dos_donts': 'করণীয় ও বর্জনীয়',
      'campaign_dos': 'করণীয়',
      'campaign_dos_1': 'দৈনন্দিন জীবনে বাস্তবভাবে পণ্য ব্যবহার দেখান।',
      'campaign_dos_2': 'ক্যাপশন পরিষ্কার এবং ব্র্যান্ড-সেইফ রাখুন।',
      'campaign_dos_3': 'মূল বার্তা ও সুবিধাগুলো হাইলাইট করুন।',
      'campaign_donts': 'বর্জনীয়',
      'campaign_donts_1':
          'একই ফ্রেমে প্রতিযোগী ব্র্যান্ড প্লেসমেন্ট এড়িয়ে চলুন।',
      'campaign_donts_2': 'অতিরঞ্জিত বা বিভ্রান্তিকর দাবি করবেন না।',
      'campaign_donts_3': 'সংবেদনশীল/অনুপযুক্ত কনটেক্সট এড়িয়ে চলুন।',

      // Assets
      'campaign_asset_logo_pack': 'ব্র্যান্ড লোগো প্যাক',
      'campaign_asset_demo_video': 'প্রোডাক্ট ডেমো ভিডিও',
      'campaign_asset_guidelines': 'ব্র্যান্ড গাইডলাইন',
      'campaign_asset_facebook_page': 'ফেসবুক পেজ',
      'campaign_asset_facebook_sub': 'ব্র্যান্ডের অফিসিয়াল পেজ লিংক',

      // Terms
      'campaign_reporting_requirements': 'রিপোর্টিং রিকোয়ারমেন্ট',
      'campaign_report_1':
          'কনটেন্ট লাইভ হওয়ার ৭ দিনের মধ্যে অ্যানালিটিক্স স্ক্রিনশট দিন।',
      'campaign_report_2': 'রিচ, ইমপ্রেশন, লিংক ক্লিক, সেভ ইত্যাদি শেয়ার করুন।',
      'campaign_usage_rights': 'ব্যবহারের অধিকার (Usage Rights)',
      'campaign_usage_1':
          'ক্রেডিটসহ ব্র্যান্ড তাদের অফিসিয়াল চ্যানেলে কনটেন্ট রিপোস্ট করতে পারে।',
      'campaign_usage_2':
          'পেইড মিডিয়া হোয়াইটলিস্টিংয়ের জন্য আলাদা লিখিত অনুমোদন প্রয়োজন।',

      // Agreement / Snackbar
      'campaign_agreement_required': 'সম্মতি প্রয়োজন',
      'campaign_agreement_required_desc': 'এগোতে শর্তাবলী গ্রহণ করুন',

      'campaign_agree_prefix': 'আপনি আমাদের ',
      'campaign_agree_ula': 'ইউজার লাইসেন্স এগ্রিমেন্ট',
      'campaign_agree_mid': ' এবং\n',
      'campaign_agree_terms': 'শর্তাবলী',
      'campaign_agree_suffix': ' গ্রহণ করছেন।',

      // Withdrawal dialog
      'campaign_withdraw_sent': 'উত্তোলনের আবেদন পাঠানো হয়েছে',
      'campaign_withdraw_msg':
          'আমরা শীঘ্রই আপনার আবেদন রিভিউ করবো।\nসময় লাগতে পারে ১–২ কর্মদিবস',

      // Milestone statuses
      'ms_paid': 'পরিশোধিত',
      'ms_partial_paid': 'আংশিক পরিশোধ',
      'ms_in_review': 'রিভিউতে',
      'ms_declined': 'বাতিল',
      'ms_todo': 'করতে হবে',

      "earnings_tab_earnings": "ইনকাম",
      "earnings_tab_transactions": "লেনদেন",
      "earnings_inner_client_list": "ক্লায়েন্ট তালিকা",
      "earnings_inner_platform": "প্ল্যাটফর্ম",

      "earnings_total_earnings": "মোট উপার্জন",
      "earnings_recent_earnings": "সাম্প্রতিক উপার্জন",
      "earnings_most_used_platform": "সর্বাধিক ব্যবহৃত প্ল্যাটফর্ম",

      "earnings_search_client_hint": "ক্লায়েন্ট খুঁজুন",
      "earnings_search_transactions_hint":
          "ক্যাম্পেইন নাম বা ক্লায়েন্ট নাম দিয়ে খুঁজুন",

      "earnings_client_header": "ক্লায়েন্ট",
      "earnings_jobs_completed": "সম্পন্ন কাজ",

      "earnings_recent_transactions_title": "সাম্প্রতিক লেনদেন",
      "earnings_showing_results": "@shown টি দেখানো হচ্ছে, মোট @total টি",

      "earnings_no_clients_found": "কোনো ক্লায়েন্ট পাওয়া যায়নি",
      "earnings_no_transactions_found": "কোনো লেনদেন পাওয়া যায়নি",

      "earnings_add_social_link": "+ সোশ্যাল লিংক যোগ করুন",
      "earnings_view_campaign_details": "ক্যাম্পেইনের বিস্তারিত দেখুন",
      "earnings_payment_for": "“@name” এর জন্য পেমেন্ট",
      "earnings_withdrawal_request": "উত্তোলনের অনুরোধ",

      "earnings_legend_thousands": "ইনকাম (হাজারে)",

      "common_low_to_high": "কম থেকে বেশি",
      "common_page": "পেজ",
      "common_of_n": "মোট @n",
      "common_next": "পরবর্তী",

      "7_days": "৭ দিন",

      "top_influencer": "সেরা ইনফ্লুয়েন্সার পার্টনার",
      "create_campaign_welcome": "স্বাগতম, User!",
      "create_campaign_dashboard": "ড্যাশবোর্ড",

      "create_campaign_step": "ধাপ",
      "create_campaign_of": " / ",

      "create_campaign_get_started_title": "চলুন শুরু করা যাক!",
      "create_campaign_get_started_subtitle":
          "আপনার নতুন ক্যাম্পেইনের প্রাথমিক তথ্যগুলো সেটআপ করুন",

      "create_campaign_name_label": "ক্যাম্পেইনের নাম",
      "create_campaign_name_hint": "ক্যাম্পেইনের নাম লিখুন",

      "create_campaign_type_label": "ক্যাম্পেইনের ধরন",
      "create_campaign_type_paid_title": "পেইড অ্যাড",
      "create_campaign_type_paid_sub":
          "টার্গেটেড বিজ্ঞাপন ক্যাম্পেইন চালু করুন",
      "create_campaign_type_influencer_title": "ইনফ্লুয়েন্সার প্রমোশন",
      "create_campaign_type_influencer_sub":
          "প্রমোশনের জন্য ইনফ্লুয়েন্সার পার্টনারশিপ করুন",

      "create_campaign_error_title": "তথ্য অসম্পূর্ণ",
      "create_campaign_error_msg":
          "ক্যাম্পেইনের নাম দিন এবং ক্যাম্পেইনের ধরন নির্বাচন করুন।",

      "common_previous": "আগের ধাপ",
      'nav_campaign': 'ক্যাম্পেইন',
      'nav_analytics': 'এনালিটিক্স',
      'nav_explore': 'এক্সপ্লোর',
      'create_campaign_step2_title': 'আপনার পছন্দসমূহ',
      'create_campaign_step2_subtitle':
          'এই ক্যাম্পেইনের জন্য আপনার পছন্দগুলো উল্লেখ করুন',
      'create_campaign_save_draft': 'ড্রাফট হিসেবে সেভ করুন',
      'create_campaign_product_type_label': 'পণ্যের ধরন নির্বাচন করুন',
      'create_campaign_product_type_hint': 'পণ্যের ধরন নির্বাচন করুন',
      'create_campaign_niche_label': 'ক্যাম্পেইনের নিশ (Niche)',
      'create_campaign_niche_hint': 'ক্যাম্পেইনের নিশ নির্বাচন করুন',
      'create_campaign_preferred_influencers_label': 'পছন্দের ইনফ্লুয়েন্সারগণ',
      'create_campaign_preferred_influencers_hint':
          'ইনফ্লুয়েন্সারদের নাম লিখুন... (কমা দিয়ে আলাদা করুন)',
      'create_campaign_not_preferred_influencers_label':
          'অপছন্দের ইনফ্লুয়েন্সারগণ',
      'create_campaign_not_preferred_influencers_hint':
          'ইনফ্লুয়েন্সারদের নাম লিখুন... (কমা দিয়ে আলাদা করুন)',
      'create_campaign_chip_empty': 'এখনও কিছু যোগ করা হয়নি',
      'create_campaign_draft_title': 'ড্রাফট সেভ হয়েছে',
      'create_campaign_draft_msg': 'আপনার ক্যাম্পেইনের ড্রাফট সেভ করা হয়েছে।',
      'create_campaign_error_step2_msg':
          'অনুগ্রহ করে পণ্যের ধরন এবং নিশ নির্বাচন করুন।',
      'common_done': 'ঠিক আছে',
      'create_campaign_step2_missing_type':
          'আগে ক্যাম্পেইনের ধরন নির্বাচন করুন।',
      'create_campaign_recommended_agencies_label': 'প্রস্তাবিত অ্যাড এজেন্সি',
      'create_campaign_other_agencies_label': 'অন্যান্য অ্যাড এজেন্সি',

      "create_campaign_step3_title": "ক্যাম্পেইনের বিস্তারিত",
      "create_campaign_step3_subtitle":
          "প্রয়োজনীয়তা এবং বিস্তারিত ব্রিফ প্রদান করুন।",

      "create_campaign_goals_label": "ক্যাম্পেইনের লক্ষ্য",
      "create_campaign_goals_hint":
          "আপনার ক্যাম্পেইনের লক্ষ্য সম্পর্কে সংক্ষিপ্তভাবে লিখুন",

      "create_campaign_product_service_label": "পণ্য বা সেবার বিবরণ",
      "create_campaign_product_service_hint":
          "আপনার পণ্য/সেবা সম্পর্কে সংক্ষিপ্তভাবে লিখুন",

      "create_campaign_dos_donts_label": "করণীয় এবং বর্জনীয় (Do’s & Don’ts)",
      "create_campaign_dos_label": "করণীয়",
      "create_campaign_dos_hint":
          "উদাহরণ:\n• আসল ব্যবহারের দৃশ্য দেখান, পরিবেশবান্ধব দিক উল্লেখ করুন\n• সব পোস্টে @StyleCo ট্যাগ করুন\n• প্রাকৃতিক আলোতে পণ্য দেখান\n• ক্যাপশনে ডিসকাউন্ট কোড দিন",
      "create_campaign_donts_label": "বর্জনীয়",
      "create_campaign_donts_hint":
          "উদাহরণ:\n• প্রতিযোগী ব্র্যান্ডের নাম উল্লেখ করবেন না\n• অতিরিক্ত কড়া আলো ব্যবহার করবেন না\n• পণ্যের সুবিধা নিয়ে বিভ্রান্তিকর তথ্য দেবেন না",

      "create_campaign_terms_label": "শর্তাবলী",

      "create_campaign_reporting_requirements_label": "রিপোর্টিং-এর শর্তাবলী",
      "create_campaign_reporting_requirements_hint":
          "রিপোর্টিং-এর প্রয়োজনীয়তা বিস্তারিত লিখুন",

      "create_campaign_usage_rights_label": "কনটেন্ট ব্যবহারের অধিকার",
      "create_campaign_usage_rights_hint":
          "ব্যবহারের অধিকার সম্পর্কে বিস্তারিত লিখুন",

      "create_campaign_start_date_label": "শুরুর তারিখ",
      "create_campaign_start_date_hint": "শুরুর তারিখ নির্বাচন করুন",

      "create_campaign_duration_label": "সময়কাল (বা মেয়াদ)",
      "create_campaign_duration_hint": "৫ দিন",

      "create_campaign_step4_title": "প্লেসমেন্ট ও বাজেট",
      "create_campaign_step4_subtitle":
          "আপনার বাজেট নির্ধারণ করুন এবং প্লেসমেন্টসহ মাইলস্টোন সেট করুন",
      "create_campaign_step4_suggestions": "প্রস্তাবিত বাজেট",
      "create_campaign_step4_enter_budget": "বাজেট এর পরিমাণ লিখুন",
      "create_campaign_step4_min": "সর্বনিম্ন",
      "create_campaign_step4_quote": "দরপত্র (বাজেট বিভাজন)",
      "create_campaign_step4_base": "মূল ক্যাম্পেইন বাজেট",
      "create_campaign_step4_vat": "+ ভ্যাট/ট্যাক্স ({p}%)",
      "create_campaign_step4_total": "ট্যাক্সসহ বাজেট",
      "create_campaign_step4_net_payable": "নেট প্রদেয় বাজেট (ট্যাক্সসহ)",
      "create_campaign_step4_milestones": "ক্যাম্পেইন মাইলস্টোনসমূহ",
      "create_campaign_step4_add_milestone": "+ আরো একটি মাইলস্টোন যোগ করুন",
      "create_campaign_step4_milestone_title_hint":
          "যেমন: Initial Content Creation",
      "create_campaign_step4_milestone_platform_hint":
          "প্ল্যাটফর্ম নির্বাচন করুন",
      "create_campaign_step4_milestone_deliverable_hint":
          "১টি স্পন্সরড ভিডিও / ১টি পোস্ট",
      "create_campaign_step4_milestone_day_hint": "DAY 1",
      "create_campaign_step4_promo_target": "প্রমোশন টার্গেট (লক্ষ্যমাত্রা)",
      "create_campaign_step4_reach": "রিচ",
      "create_campaign_step4_views": "ভিউস",
      "create_campaign_step4_likes": "লাইক",
      "create_campaign_step4_comments": "কমেন্টস",
      "create_campaign_step4_milestone_error":
          "মাইলস্টোনের সব ফিল্ড পূরণ করুন।",
      "create_campaign_milestone_platform": "প্ল্যাটফর্ম",
      "create_campaign_milestone_day": "দিন",
      "create_campaign_step5_title": "আপনার কন্টেন্ট আপলোড করুন",
      "create_campaign_step5_subtitle":
          "ইনফ্লুয়েন্সারদের জন্য ক্যাম্পেইনের কন্টেন্ট আপলোড করুন",
      "create_campaign_content_assets": "প্রয়োজনীয় ফাইলসমূহ",
      "create_campaign_upload_another_asset": "আরও ফাইল আপলোড করুন",

      "create_campaign_need_sample_title": "পণ্যের নমুনা পাঠাতে হবে কি?",
      "create_campaign_need_sample_label": "স্যাম্পল পাঠানো প্রয়োজন",
      "create_campaign_confirm_sample_guidelines":
          "নিশ্চিত করুন যে আপনি স্যাম্পল সেন্ডিং গাইডলাইনস পড়েছেন",

      "create_campaign_brand_assets": "ব্র্যান্ড ফাইলসমূহ",
      "create_campaign_add_brand_asset": "+ আরও ব্র্যান্ড অ্যাসেট অ্যাড করুন",

      "create_campaign_asset_name_hint": "ফাইলের নাম (যেমন: Brand Logo Pack)",
      "create_campaign_asset_meta_hint": "বিবরণ (যেমন: PNG, SVG - 2.4 MB)",
      "create_campaign_asset_error": "ফাইলের নাম ও বিবরণ দিন।",

      "create_campaign_brand_asset_name_hint":
          "অ্যাসেটের নাম (যেমন: Facebook Page)",
      "create_campaign_brand_asset_value_hint": "পেজ লিংক",
      "create_campaign_brand_asset_error": "ব্র্যান্ড অ্যাসেটের নাম দিন।",
      "create_campaign_pick_file": "ফাইল নির্বাচন করুন",
      "create_campaign_picking_file": "নির্বাচন করা হচ্ছে...",
      "create_campaign_no_file_selected": "এখনও কোনো ফাইল নির্বাচন করা হয়নি।",

      "create_campaign_step6_title": "আপনার ক্যাম্পেইন যাচাই করুন",
      "create_campaign_step6_subtitle":
          "আপনার প্রোমোশনাল ক্যাম্পেইনের সংক্ষিপ্ত রিক্যাপ দেখুন",
      "create_campaign_step6_campaign_details": "ক্যাম্পেইন বিস্তারিত",
      "create_campaign_step6_summer_fashion_campaign": "সামার ফ্যাশন ক্যাম্পেইন",
      "create_campaign_step6_campaign_title_fallback": "শিরোনামহীন ক্যাম্পেইন",
      "create_campaign_step6_deadline": "সময়সীমা",
      "create_campaign_step6_including_vat": "ভ্যাট/ট্যাক্সসহ ({vat})",

      "create_campaign_step6_campaign_brief": "ক্যাম্পেইন ব্রিফ",
      "create_campaign_step6_campaign_milestones": "ক্যাম্পেইন মাইলস্টোন",
      "create_campaign_step6_content_assets": "কনটেন্ট অ্যাসেটস",
      "create_campaign_step6_terms_conditions": "শর্তাবলী",
      "create_campaign_step6_brand_assets": "ব্র্যান্ড অ্যাসেটসমূহ",

      "create_campaign_step6_campaign_goals": "ক্যাম্পেইনের লক্ষ্য",
      "create_campaign_step6_product_service": "পণ্য/সেবার বিবরণ",
      "create_campaign_step6_content_requirements": "কনটেন্টের প্রয়োজনীয়তা",
      "create_campaign_step6_dos_donts": "করণীয় এবং বর্জনীয়",
      "create_campaign_step6_dos": "করণীয়",
      "create_campaign_step6_donts": "বর্জনীয়",

      "create_campaign_step6_total_budget": "ক্যাম্পেইনের মোট বাজেট",
      "create_campaign_step6_budget_including_vat": "+ ভ্যাট/ট্যাক্সসহ ({vat})",

      "create_campaign_step6_reporting_requirements":
          "রিপোর্টিং-এর প্রয়োজনীয়তা",
      "create_campaign_step6_usage_rights":
          "কনটেন্ট ব্যবহারের অধিকার (Usage Rights)",

      "create_campaign_step6_get_quote": "কোটেশন দিন",
      "create_campaign_step6_submit_title": "সাবমিট হয়েছে",
      "create_campaign_step6_submit_msg":
          "আপনার ক্যাম্পেইন সফলভাবে সাবমিট হয়েছে।",

      'create_campaign_step6_popup_title':
          'ক্যাম্পেইন প্লেসমেন্ট নিশ্চিত হয়েছে',
      'create_campaign_step6_popup_message':
          'আমরা শীঘ্রই আপনার ক্যাম্পেইনটি পর্যালোচনা করব।\nএতে সাধারণত ৩–৫ কর্মদিবস সময় লাগতে পারে।',
      'create_campaign_preferred_influencers_hint': 'প্রভাবশালীদের নাম লিখুন...(প্রতিটি নাম কমা দিয়ে আলাদা করুন)',
      'create_campaign_preferred_influencers_label': 'পছন্দের প্রভাবশালী',
      'create_campaign_not_preferred_influencers_label': 'পছন্দের নয় এমন প্রভাবশালী',

          'brand_campaign_details_welcome': 'স্বাগতম, User!',
      'brand_campaign_details_campaign_details': 'ক্যাম্পেইন ডিটেইলস',
      'brand_campaign_details_influencers': 'ইনফ্লুয়েন্সার',
      'brand_campaign_details_platforms': 'প্ল্যাটফর্ম',
      'brand_campaign_details_deadline': 'ডেডলাইন',
      'brand_campaign_details_days_remaining': 'দিন বাকি',
      'brand_campaign_details_budget_pending': 'বাজেট পেন্ডিং',

      'brand_campaign_details_campaign_progress': 'ক্যাম্পেইন স্ট্যাটাস',
      'brand_campaign_details_submitted': 'জমা দেয়া হয়েছে',
      'brand_campaign_details_submitted_sub':
          'ক্যাম্পেইন রিকোয়েস্ট পাঠানো হয়েছে',
      'brand_campaign_details_quoted': 'কোটেড',
      'brand_campaign_details_quoted_sub': 'কোট প্রদান করা হয়েছে',
      'brand_campaign_details_paid': 'পেইড',
      'brand_campaign_details_paid_sub': 'পেমেন্ট প্রসেসড',
      'brand_campaign_details_promoting': 'প্রমোটিং',
      'brand_campaign_details_promoting_sub': 'কনটেন্ট লাইভ',
      'brand_campaign_details_completed': 'কমপ্লিটেড',
      'brand_campaign_details_completed_sub': 'ক্যাম্পেইন শেষ',

      'brand_campaign_details_quote_details': 'কোটেশন ডিটেইলস',
      'brand_campaign_details_base_campaign_budget': 'বেস ক্যাম্পেইন বাজেট',
      'brand_campaign_details_vat_tax': 'ভ্যাট/ট্যাক্স (১৫%)',
      'brand_campaign_details_total_campaign_cost': 'মোট ক্যাম্পেইন খরচ',
      'brand_campaign_details_request_quote': 'রিকোয়েস্ট',
      'brand_campaign_details_accept_quote': 'কোট একসেপ্ট',
      'brand_campaign_details_quote': 'কোট',
      'brand_campaign_details_request_quote_msg': 'রিকোয়েস্ট পাঠানো হয়েছে।',
      'brand_campaign_details_accept_quote_msg': 'কোট একসেপ্ট হয়েছে।',

      'brand_campaign_details_campaign_milestones': 'ক্যাম্পেইন মাইলস্টোন',
      'brand_campaign_details_campaign_not_started': 'ক্যাম্পেইন শুরু হয়নি',
      'brand_campaign_details_progress': 'প্রগ্রেস',
      'brand_campaign_details_of': 'এর মধ্যে',
      'brand_campaign_details_completed_small': 'কমপ্লিটেড',
      'brand_campaign_details_pending': 'পেন্ডিং',

      'brand_campaign_details_provide_rating': 'ইনফ্লুয়েন্সারকে রেটিং দিন',
      'brand_campaign_details_campaign_brief': 'ক্যাম্পেইন ব্রিফ',
      'brand_campaign_details_campaign_goals': 'ক্যাম্পেইন গোল',
      'brand_campaign_details_product_service': 'প্রোডাক্ট/সার্ভিস ডিটেইলস',
      'brand_campaign_details_content_requirements': 'কনটেন্ট রিকোয়ারমেন্ট',
      'brand_campaign_details_dos_donts': 'করণীয় ও বর্জনীয়',
      'brand_campaign_details_dos': 'করণীয়',
      'brand_campaign_details_donts': 'বর্জনীয়',

      'brand_campaign_details_content_assets': 'কনটেন্ট অ্যাসেটস',
      'brand_campaign_details_upload_another_asset':
          'আরেকটি অ্যাসেট আপলোড করুন',
      'brand_campaign_details_assets': 'অ্যাসেটস',
      'brand_campaign_details_download_msg': 'ডাউনলোড শুরু হয়েছে।',
      'brand_campaign_details_upload_msg': 'আপলোড ফ্লো শীঘ্রই আসছে।',

      'brand_campaign_details_terms_conditions': 'শর্তাবলী',
      'brand_campaign_details_reporting_requirements': 'রিপোর্টিং রিকোয়ারমেন্ট',
      'brand_campaign_details_usage_rights': 'ব্যবহারের অধিকার',

      'brand_campaign_details_requote': 'পুনরায় দরপত্র',

      'brand_campaign_requote_title': 'পুনরায় দরপত্র',
      'brand_campaign_requote_subtitle':
          'আপনার ক্যাম্পেইন বাজেট পুনরায় প্রস্তাব করুন',
      'brand_campaign_requote_overview': 'নতুন দরপত্রের সারসংক্ষেপ',
      'brand_campaign_requote_base': 'মূল ক্যাম্পেইন বাজেট',
      'brand_campaign_requote_vat': 'ভ্যাট/ট্যাক্স (১৫%)',
      'brand_campaign_requote_total': 'মোট ক্যাম্পেইন খরচ',
      'brand_campaign_requote_submit': 'অ্যাডমিনের কাছে পুনরায় দরপত্র পাঠান',
      'brand_campaign_requote_invalid': 'অনুগ্রহ করে সঠিক বাজেট লিখুন।',
      'brand_campaign_requote_sent':
          'অ্যাডমিনের কাছে পুনরায় দরপত্র পাঠানো হয়েছে।',

      'brand_campaign_fund_title': 'আপনার ক্যাম্পেইন ফান্ড করুন',
      'brand_campaign_fund_total_due': 'মোট বকেয়া',
      'brand_campaign_fund_minimum_label':
          'ক্যাম্পেইন শুরু করার জন্য সর্বনিম্ন ফান্ড প্রয়োজন (৫০%)',
      'brand_campaign_fund_full': 'সম্পূর্ণ পরিশোধ (১০০%)',
      'brand_campaign_fund_min': 'সর্বনিম্ন পরিশোধ (৫০%)',
      'brand_campaign_fund_75': 'পরিশোধ (৭৫%)',
      'brand_campaign_fund_method': 'পেমেন্ট পদ্ধতি',
      'brand_campaign_fund_card': 'ক্রেডিট / ডেবিট কার্ড',
      'brand_campaign_fund_bkash': 'বিকাশ',
      'brand_campaign_pay_now': 'এখন পেমেন্ট করুন',
      'brand_campaign_payment': 'পেমেন্ট',
      'brand_campaign_payment_success': 'পেমেন্ট শুরু করা হয়েছে।',
      'brand_campaign_payment_invalid':
          'পরিমাণটি সর্বনিম্ন এবং মোট বকেয়ার মধ্যে হতে হবে।',
    },
  };
}
