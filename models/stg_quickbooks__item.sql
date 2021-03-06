with base as (

    select * 
    from {{ ref('stg_quickbooks__item_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__item_tmp')),
                staging_columns=get_item_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as item_id,
        active as is_active,
        created_at,
        cast(income_account_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as income_account_id,
        cast(asset_account_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as asset_account_id,
        cast(expense_account_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as expense_account_id,
        name,
        purchase_cost,
        taxable,
        type,
        unit_price,
        inventory_start_date,
        cast(parent_item_id as {{ 'int64' if target.name == 'bigquery' else 'bigint' }}) as parent_item_id
    from fields
)

select * 
from final
