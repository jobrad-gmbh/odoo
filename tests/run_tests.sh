#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function cleanup() {
  docker compose -f tests/docker-compose.yml down -v
}

trap cleanup EXIT

docker compose -f tests/docker-compose.yml up -d
docker compose -f tests/docker-compose.yml exec odoo poetry install --only testing --no-interaction --no-cache

echo "---*** Running Odoo tests at_install ***---"
docker compose -f tests/docker-compose.yml exec odoo ./odoo-bin -d test --addons-path=addons,odoo/addons \
  -i \
base,\
account,\
account_edi,\
account_edi_facturx,\
account_edi_ubl,\
account_qr_code_sepa,\
account_test,\
analytic,\
attachment_indexation,\
auth_password_policy,\
auth_password_policy_portal,\
auth_password_policy_signup,\
auth_signup,\
auth_totp,\
auth_totp_portal,\
barcodes,\
base_automation,\
base_geolocalize,\
base_iban,\
base_import,\
base_setup,\
base_sparse_field,\
base_vat,\
board,\
bus,\
calendar,\
calendar_sms,\
contacts,\
crm,\
crm_iap_lead_enrich,\
crm_sms,\
delivery,\
digest,\
fetchmail,\
hr,\
hr_holidays,\
hr_work_entry,\
http_routing,\
iap,\
iap_crm,\
iap_mail,\
l10n_de,\
l10n_de_purchase,\
l10n_de_sale,\
l10n_de_skr03,\
l10n_de_skr04,\
l10n_de_stock,\
mail,\
mail_bot,\
mail_bot_hr,\
mrp,\
mrp_account,\
mrp_product_expiry,\
note,\
odoo_referral,\
payment,\
payment_fix_register_token,\
payment_transfer,\
phone_validation,\
portal,\
portal_rating,\
procurement_jit,\
product,\
product_expiry,\
project,\
purchase,\
purchase_mrp,\
purchase_stock,\
rating,\
resource,\
sale,\
sale_crm,\
sale_management,\
sale_mrp,\
sale_project,\
sale_purchase,\
sale_purchase_stock,\
sale_stock,\
sales_team,\
sms,\
snailmail,\
snailmail_account,\
social_media,\
stock,\
stock_account,\
stock_dropshipping,\
stock_sms,\
uom,\
utm,\
web,\
web_editor,\
web_kanban_gauge,\
web_tour,\
web_unsplash,\
website,\
website_crm_sms,\
website_mail,\
website_partner,\
website_sms \
  --test-enable --test-tags=-post_install \
  --stop-after-init

echo "---*** Running Odoo tests post_install ***---"
docker compose -f tests/docker-compose.yml exec odoo ./odoo-bin -d test --addons-path=addons,odoo/addons \
  --test-enable --test-tags=\
/base,\
/account,\
/account_edi,\
/account_edi_facturx,\
/account_edi_ubl,\
/account_qr_code_sepa,\
/account_test,\
/analytic,\
/attachment_indexation,\
/auth_password_policy,\
/auth_password_policy_portal,\
/auth_password_policy_signup,\
/auth_signup,\
/auth_totp,\
/auth_totp_portal,\
/barcodes,\
/base_automation,\
/base_geolocalize,\
/base_iban,\
/base_import,\
/base_setup,\
/base_sparse_field,\
/base_vat,\
/board,\
/bus,\
/calendar,\
/calendar_sms,\
/contacts,\
/crm,\
/crm_iap_lead_enrich,\
/crm_sms,\
/delivery,\
/digest,\
/fetchmail,\
/hr,\
/hr_holidays,\
/hr_work_entry,\
/http_routing,\
/iap,\
/iap_crm,\
/iap_mail,\
/l10n_de,\
/l10n_de_purchase,\
/l10n_de_sale,\
/l10n_de_skr03,\
/l10n_de_skr04,\
/l10n_de_stock,\
/mail,\
/mail_bot,\
/mail_bot_hr,\
/mrp,\
/mrp_account,\
/mrp_product_expiry,\
/note,\
/odoo_referral,\
/payment,\
/payment_fix_register_token,\
/payment_transfer,\
/phone_validation,\
/portal,\
/portal_rating,\
/procurement_jit,\
/product,\
/product_expiry,\
/project,\
/purchase,\
/purchase_mrp,\
/purchase_stock,\
/rating,\
/resource,\
/sale,\
/sale_crm,\
/sale_management,\
/sale_mrp,\
/sale_project,\
/sale_purchase,\
/sale_purchase_stock,\
/sale_stock,\
/sales_team,\
/sms,\
/snailmail,\
/snailmail_account,\
/social_media,\
/stock,\
/stock_account,\
/stock_dropshipping,\
/stock_sms,\
/uom,\
/utm,\
/web,\
/web_editor,\
/web_kanban_gauge,\
/web_tour,\
/web_unsplash,\
/website,\
/website_crm_sms,\
/website_mail,\
/website_partner,\
/website_sms,\
-at_install \
  --stop-after-init
docker compose -f tests/docker-compose.yml down -v

