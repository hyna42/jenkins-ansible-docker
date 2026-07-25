pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    environment {
        REGISTRY_PROJET = 'hyna42/war-build-docker'
        IMAGE = "${REGISTRY_PROJET}:version-${env.BUILD_ID}"
    }

    stages {
        // Cloner le dépôt qui contient le Jenkinsfile, le playbook Ansible et les rôles de déploiement
        stage("Clone") {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/hyna42/jenkins-ansible-docker.git'
            }
        }

        // Vérifier que Jenkins peut bien joindre la machine cible en SSH avant d'aller plus loin (smoke test)
        stage("ping") {
            steps {
                sh 'ls -la /var/jenkins_home/.ssh/id_ed25519.pub'
                sh 'ansible all -m ping'
            }
        }

        // Cloner le dépôt de l'application à builder (le code source Java/Maven, séparé du dépôt d'orchestration)
        stage("Build - Clone") {
            steps {
                git branch: 'main', credentialsId: 'github-for-jenkins', url: 'https://github.com/hyna42/war-build-docker.git'
            }
        }

        // Compiler l'application et générer le livrable .war via Maven
        stage("Build - Maven package") {
            steps {
                sh 'mvn package'
            }
        }

        // Construire l'image Docker à partir du .war généré
        stage("Build - Docker Image") {
            steps {
                script {
                    img = docker.build("${IMAGE}", '.')
                }
            }
        }

        // Test de fumée : lancer l'image en conteneur éphémère et vérifier qu'elle répond avant publication
        stage("Build - Test") {
            steps {
                script {
                    img.withRun("--name run-${env.BUILD_ID} -p 8083:8080") {
                        sh 'docker ps'
                        sh 'ss -tlnp'
                        sh 'sleep 15s'
                        sh 'curl http://192.168.11.129:8083'
                        sh 'docker ps'
                    }
                }
            }
        }

        // Publier l'image validée sur Docker Hub
        stage("Build - Push") {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-credentials') {
                        img.push('latest')
                        img.push()
                    }
                }
            }
        }

        // Recloner le dépôt d'orchestration avant le déploiement
        stage("Deploy - Clone") {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/hyna42/jenkins-ansible-docker.git'
            }
        }

        // Déployer l'image via Ansible sur la machine cible
        stage("Deploy - End - Nginx") {
            steps {
                script {
                    if (!params.HOSTS?.trim()) {
                        error("Le paramètre HOSTS est vide — impossible de déployer sans cible.")
                    }
                }
                ansiblePlaybook(
                    colorized: true,
                    become: true,
                    playbook: 'playbook.yml',
                    inventory: "hosts.yml",
                    extras: "-u root -e image=${IMAGE}"
                )
            }
        }
    }
}
