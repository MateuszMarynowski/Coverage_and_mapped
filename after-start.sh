### start time
docker_size=$(du -achx / | tail -n 1 | awk 'NR==1{print $1}')
echo "$docker_size" > docker_size
date +%s > starttime
echo "##################################################$task_name_with_index##################################################"
>&2 echo "##################################################$task_name_with_index##################################################"

