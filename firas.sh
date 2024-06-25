stages:
  - build
  - promote

buildBackJavaDocker:
  stage: build
  script:
    - echo "Visualisation repertoire livrable"
    - ls target/
    - docker build --pull --no-cache --build-arg HTTP_PROXY=$HTTP_PROXY --build-arg HTTPS_PROXY=$HTTPS_PROXY --build-arg JDK_VERSION_IMAGE=$JDK_VERSION_IMAGE -t prez-tribu-back:$version_tag .
    - docker tag prez-tribu-back:$version_tag $ARTIFACTORY_REGISTRY_SCRATCH/prez-tribu-back:$version_tag
    - docker push $ARTIFACTORY_REGISTRY_SCRATCH/prez-tribu-back:$version_tag
  after_script:
    - docker logout $ARTIFACTORY_REGISTRY_SCRATCH
  only:
    - main

promote_back_to_tagging:
  stage: promote
  image: layer-kraft.registry.saas.capg.group.gca/ci-tools:latest
  before_script:
    - export PROMOTE_TOKEN=$(kubi token --kubi-url kubi.prod.managed.lcl.gca --username $ARTIFACTORY_USER_ACCOUNT_HORS_PROD --password $ARTIFACTORY_USER_PASSWORD_HORS_PROD)
  needs: [buildBackJavaDocker]
  script:
    - echo '{"paths":["artifactory/lcl1bdev-05975.metier-docker-scratch-intranet/prez-tribu-back/1.0.4"]}' > data.json
    - cat data.json
    - echo 'Constructed curl command:'
    - echo "curl --location \"https://registry.saas.capg.group.gca/xray/api/v1/summary/artifact\" --header \"Authorization: Bearer ${TOKEN_XRAY}\" --header \"Content-Type: application/json\" --data @data.json -o response.json"
    - curl --location "https://registry.saas.capg.group.gca/xray/api/v1/summary/artifact" --header "Authorization: Bearer ${TOKEN_XRAY}" --header "Content-Type: application/json" --data @data.json -o response.json
    - cat response.json
  only:
    - promote

promote_back_to_prod:
  stage: promote
  image: layer-kraft.registry.saas.capg.group.gca/ci-tools:latest
  before_script:
    - export PROMOTE_TOKEN=$(kubi token --kubi-url kubi.prod.managed.lcl.gca --username $ARTIFACTORY_USER_ACCOUNT_HORS_PROD --password $ARTIFACTORY_USER_PASSWORD_HORS_PROD)
  script:
    - echo '{"paths":["artifactory/lcl1bdev-05975.metier-docker-scratch-intranet/prez-tribu-back/1.0.4"]}' > data.json
    - cat data.json
    - echo 'Constructed curl command:'
    - echo "curl --location \"https://registry.saas.capg.group.gca/xray/api/v1/summary/artifact\" --header \"Authorization: Bearer ${TOKEN_XRAY}\" --header \"Content-Type: application/json\" --data @data.json -o response.json"
    - curl --location "https://registry.saas.capg.group.gca/xray/api/v1/summary/artifact" --header "Authorization: Bearer ${TOKEN_XRAY}" --header "Content-Type: application/json" --data @data.json -o response.json
    - cat response.json
  only:
    - promote
