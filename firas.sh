Based on the provided image, it looks like the data.json file is correctly containing the version tag, and the script is executing as expected. However, you want to see the high_count and critical_count in a table format.

Let's update the script to print a more structured table format for high_count and critical_count.

Here's the updated script portion in your .gitlab-ci.yml file:

yaml
Copier le code
promote_back_to_staging:
  stage: promote
  image: layer-kraft.registry.saas.capig.group.gca/ci-tools:latest
  before_script:
    - export PROMOTE_TOKEN=$(kubi token --kubi-url kubi.prod.managed.lcl)
  needs: [buildBackJavaDocker]
  script:
    - docker logout $ARTIFACTORY_REGISTRY_SCRATCH --username $ARTIFACTORY_USER_ACCOUNT_HORS_PROD --password $ARTIFACTORY_USER_PASSW0RD_HORS_PROD
    - echo "{\"paths\":[\"artifactory/lcl-libdev-05075-metier-docker-scratch.intranet/prez-tribu-back/${version_tag}\"]}" > data.jsonrpromote_back_to_staging:
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
    - jq --version  # Check jq version
    - |
      # Check for high or critical severity issues using jq
      data=$(cat response.json)
      high_count=$(echo "$data" | jq '[.artifacts[]?.issues[]? | select(.severity | ascii_downcase == "high")] | length')
      critical_count=$(echo "$data" | jq '[.artifacts[]?.issues[]? | select(.severity | ascii_downcase == "critical")] | length')
      echo "Nombre de problèmes de gravité élevée : $high_count"
      echo "Nombre de problèmes de gravité critique : $critical_count"
      if [ "$high_count" -gt 0 ] || [ "$critical_count" -gt 0 ]; then
        echo "Blocage en raison d'un problème de gravité élevée ou critique trouvé."
        exit 1
      else
        echo "Aucun problème de gravité élevée ou critique trouvé."
      fi
  when: manual
Quiz sur les Microservices

Qu'est-ce qu'un microservice ?

A. Une grande application monolithique
B. Une petite application indépendante exécutant une fonction spécifique
C. Une base de données partagée par plusieurs applications
Quels outils sont utilisés pour scanner les images de conteneurs ?

A. Visual Studio Code
B. Trivy, Clair, JFrog Xray
C. Slack
Pourquoi doit-on surveiller les images des microservices ?

A. Pour améliorer la vitesse de développement
B. Pour détecter et corriger les vulnérabilités, assurer la conformité, et maintenir la performance
C. Pour réduire le coût des licences logicielles


flowchart TD
  subgraph Intranet
    subgraph Staging
      A1[Utilisateur habilité sur projet "bleu"]
      B1[Utilisateur habilité sur projet "jaune"]
      C1[CustomerOps habilité]
    end
    subgraph Stable
      A2[Utilisateur habilité sur projet "bleu"]
      B2[Utilisateur habilité sur projet "jaune"]
      C2[CustomerOps habilité]
    end
  end
  
  subgraph Extranet
    subgraph Stable
      A3[Utilisateur habilité sur projet "bleu"]
      B3[Utilisateur habilité sur projet "jaune"]
      C3[CustomerOps habilité]
    end
  end

  A1 --> A2
  B1 --> B2
  C1 --> C2
  A2 --> A3
  B2 --> B3
  C2 --> C3




flowchart ah TD
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
