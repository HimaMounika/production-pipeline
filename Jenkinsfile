def performsfsDeployment(String share) {
    stage("${share}") {
        echo "Building the ${share}"
		echo "${nexusversion}"
		sh "sh rmindex.sh"
		sh "rsync -avh ${share} intershop1@${share}:/opt/intershop/install/new_workspace"
		sh "ssh -t intershop1@${share} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${share}/deploy.sh"
        }
    
}

def performAppserverDeployment(String appservers) {
    stage("${appservers}") {
        echo "Building the ${appservers}"
		echo "${nexusversion}"
		sh "rsync -avh ${appservers} intershop1@${appservers}:/opt/intershop/install/new_workspace"
		sh "ssh -t intershop1@${appservers} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${appservers}/deploy.sh"
		sh "sh statuscodecheck.sh ${appservers}"
		}
}

def performWebserverDeployment(String webservers) {
    stage("${webservers}") {
        echo "Building the ${webservers}"
		echo "${nexusversion}"
		sh "rsync -avh ${webservers} intershop1@${webservers}:/opt/intershop/install/new_workspace --delete-before"
		sh "ssh -t intershop1@${webservers} ASSEMBLY=${nexusversion} sh /opt/intershop/install/new_workspace/${webservers}/deploy.sh"

	    script {
	        
	        if ( params.InvalidatePagecache == true ){
            sh "ssh -t intershop1@${webservers} sh /opt/intershop/install/new_workspace/${webservers}/invalidate_pagecache.sh -o soft"
	        }else {
	            echo "Pagecache is not Invalidated!"
	        }
	        
	    }
        }
    
}



pipeline {
    agent {
        label 'pls-bld-l01'
    }
    parameters {
		string(name: 'nexusversion',defaultValue: 'NIL', 											 description: 'Nexus Version Number', trim: true)
		string(name: 'sfs', 		defaultValue: 'pls-sfs-l02', 									 description: 'SFS Node')
	    string(name: 'appslist1', 	defaultValue: 'pls-aps-l03,pls-aps-l04,pls-aps-l05,pls-aps-l06', description: 'App Nodes')
        string(name: 'appslist2', 	defaultValue: 'pls-aps-l07,pls-aps-l09,pls-aps-l10,pls-aps-l11', description: 'App Nodes')
		string(name: 'weblist1',   	defaultValue: 'pls-www-l03,pls-www-l04,pls-www-l05', 						 description: 'Web Nodes')
		booleanParam                defaultValue: false, description: 'Check to remove pagecache', name: 'InvalidatePagecache'
    }

environment {
		
			def nexusversion = "${params.nexusversion}"
		}

    stages {
	 
	 stage('share') {
	       when {
                expression { nexusversion != 'NIL' }
                    
           }
				steps {
					script {
						def sfs = [:]
						for (share in params.sfs.tokenize(',')) {
							performsfsDeployment(share)
							
						}
						
					}
				}
			}

	 stage('Pauze PRTG sensors') {
        	steps {
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=2070&pausemsg=deployment&action=0&username=deploymentplus&passhash=1912947534')
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=5737&pausemsg=deployment&action=0&username=deploymentplus&passhash=1912947534')
            }	
        }

	 stage('apps') {
	    parallel {
			stage('apps1') {
			
			when {
                expression { nexusversion != 'NIL' }
                    
            }
				steps {
					script {
						def appslist1 = [:]
						for (appservers in params.appslist1.tokenize(',')) {
							performAppserverDeployment(appservers)
							
						}
						
					}
				}
			}
			
			stage('apps2') {
	        when {
                expression { nexusversion != 'NIL' }
                    
            }
				steps {
					script {
						def appslist2 = [:]
						for (appservers in params.appslist2.tokenize(',')) {
							performAppserverDeployment(appservers)
							
						}
						
					}
				}
			}
		}
	}
	

	  stage('web') {
	  
	       when {
                expression { nexusversion != 'NIL' }
                    
           }
				steps {
					script {
						def weblist1 = [:]
						for (webservers in params.weblist1.tokenize(',')) {
							performWebserverDeployment(webservers)
							
						}
						
					}
				}
			}
	 
	  stage('Resume PRTG sensors') {
        	steps {
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=2070&action=1&username=deploymentplus&passhash=1912947534')
				httpRequest('https://prtg.eperium.nl/api/scannow.htm?id=2070&username=deploymentplus&passhash=1912947534')
				httpRequest('https://prtg.eperium.nl/api/pause.htm?id=5737&action=1&username=deploymentplus&passhash=1912947534')
				httpRequest('https://prtg.eperium.nl/api/scannow.htm?id=5737&username=deploymentplus&passhash=1912947534')
            }	
        }
	
}
}
