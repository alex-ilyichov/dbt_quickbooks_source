with base as (

    select * 
    from {{ ref('stg_quickbooks__vendor_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__vendor_tmp')),
                staging_columns=get_vendor_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as vendor_id,
        account_number,
        active as is_active,
        balance,
        billing_address_id,
        company_name,
        created_at,
        currency_id,
        display_name,
        vendor_1099 as is_vendor_1099
    from fields
)

select * 
from final
