
flowchart TD
  subgraph Intranet
    subgraph Staging
      A1[User - Projet "bleu"]
      B1[User - Projet "jaune"]
      C1[CustomerOps]
    end
    subgraph Stable
      A2[User - Projet "bleu"]
      B2[User - Projet "jaune"]
      C2[CustomerOps]
    end
  end
  
  subgraph Extranet
    subgraph Stable
      A3[User - Projet "bleu"]
      B3[User - Projet "jaune"]
      C3[CustomerOps]
    end
  end

  A1 --> A2
  B1 --> B2
  C1 --> C2
  A2 --> A3
  B2 --> B3
  C2 --> C3




stateDiagram-v2
    [*] --> ValidateJSON
    ValidateJSON --> CheckSeverity: JSON Validated
    CheckSeverity --> HighOrCriticalIssueFound: Severity Check
    HighOrCriticalIssueFound --> BlockProcess: High or Critical Issue
    HighOrCriticalIssueFound --> NoIssueFound: No High or Critical Issue
    BlockProcess --> [*]: Process Blocked
    NoIssueFound --> [*]: No Issues Found
promote_back_to_staging:
  stage: promote
  image: layer-kraft.registry.saas.capig.group.gca/ci-tools:latest
  before_script:
    - export PROMOTE_TOKEN=$(kubi token --kubi-url kubi.prod.managed.lcl)
  needs: [buildBackJavaDocker]
  script:
    - docker logout $ARTIFACTORY_REGISTRY_SCRATCH --username $ARTIFACTORY_USER_ACCOUNT_HORS_PROD --password $ARTIFACTORY_USER_PASSW0RD_HORS_PROD
    - echo '{"paths":["artifactory/lcl-libdev-05075-metier-docker-scratch.intranet/prez-tribu-back/1.0.4"]}' > data.json
    - cat data.json
    - echo "Constructed curl command:"
    - curl --location "https://registry.saas.capig.group.gca/xray/api/v1/summary/artifact" --header "Authorization:${TOKEN_XRAY}" --header "Content-Type:application/json" --data @data.json > response.json
    - apt-get update && apt-get install -y jq
    - |
      # Check for high or critical severity issues using jq
      data=$(cat response.json)
      blocker_found=$(echo "$data" | jq '[.artifacts[]?.issues[]? | select(.severity | ascii_downcase == "high" or ascii_downcase == "critical")] | length')
      if [ "$blocker_found" -gt 0 ]; then
        echo "Blocage en raison d'un problème de gravité élevée ou critique trouvé."
        exit 1
      else
        echo "Aucun problème de gravité élevée ou critique trouvé."
      fi
  when: manual
