### start time
date +%s > starttime
echo "##################################################$task_name_with_index##################################################"
>&2 echo "##################################################$task_name_with_index##################################################"
docker_size=$(du -ach / | tail -n 1 | awk 'NR==1{print $1}')
echo "$docker_size" > docker_size
