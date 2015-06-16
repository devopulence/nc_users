# Set up defaults for this cookbook
default['nc_users']['cookbook']['skip']=false

default['news_corp']['vaults']['nc_user']['owner']= "johndesp"
default['news_corp']['vaults']['nc_user']['action']="active"
default['news_corp']['vaults']['dj_user']['owner']= "joettedesp"
default['news_corp']['vaults']['dj_user']['action']="remove"


# Default databag name for nc_users
default['nc_users']['databag']= "nc_user"


default['environment_role']= 'webtier'




default[:nc_secure_home][:home_path] = "/home"

# Data bag name
default[:nc_local_users][:dbag]		= "nc_local_users"

# Search Query
default[:nc_local_users][:s_query]	= "default:true"

# System accounts item
default[:nc_local_users][:sys_item]	= "system_accounts"

# Default user settings
default[:nc_local_users][:d_shell]  	= "/bin/bash"
default[:nc_local_users][:force_delete]	= true
default[:nc_local_users][:manage_home]	= true
default[:nc_local_users][:non_unique]	= false



default['endpoints']['apptier']['instances']['akos']['ajp_port'] ="8009"
default['endpoints']['apptier']['instances']['akos']['ip'] ="3.166.223.148"
default['endpoints']['apptier']['instances']['akos']['http_port'] ="8080"
default['endpoints']['apptier']['instances']['akos']['basecontext'] ="akos"

default['endpoints']['apptier']['instances']['jd']['ajp_port'] ="8009"
default['endpoints']['apptier']['instances']['jd']['ip'] ="3.166.223.148"
default['endpoints']['apptier']['instances']['jd']['http_port'] ="8080"
default['endpoints']['apptier']['instances']['jd']['basecontext'] ="akos"
