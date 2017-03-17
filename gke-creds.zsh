gke-creds() {
  name_rxp="^[-a-z0-9]+"
  project=$1
  cluster=$2

  # Select the project if not specified as the first argument
  if [ -z "$project" ] ; then
    projects=($(gcloud projects list | grep -oE "$name_rxp" | tr "\n" " "))
    select selected in $projects ; do
      project="$selected"
      break
    done
  fi

  # Select the cluster if not specified as the second argument
  if [ -z "$cluster" ] ; then
    clusters=($(gcloud container clusters list --project=$project | grep -oE "$name_rxp" | tr "\n" " "))
    count=${#clusters[@]}

    # Select the cluster if there are more than one in the project
    if [[ "$count" > "1" ]] ; then
      select selected in $clusters ; do
        cluster="$selected"
        break
      done

    # Auto select the cluster if there is only one in the project
    elif [[ "$count" == "1" ]] ; then
      cluster="$clusters"

    # Error if there are no clusters in the project
    else
      echo "No clusters found!"
      return 1
    fi
  fi

  # Determine the zone of the selected cluster
  zone=$(gcloud container clusters list --project=$project | grep -oE "^$cluster +[-a-z0-9]+" | sed -E "s/[-a-z0-9]+//" | tr -d ' ')

  # Gather the credentials
  gcloud container clusters get-credentials $cluster --project=$project --zone=$zone
}
