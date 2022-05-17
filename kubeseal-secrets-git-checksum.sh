echo "Iniciando...."
#Verifica se a pasta que sera utilizada para o clone deste repo existe, caso sim apaga para pegar uma versão mais recente.

if [ -d "k8s" ]; then rm -Rf k8s; fi

#Desabilita a verificação de ssl
git config --global http.sslverify false

#Efetua o clone do repositório. Deve se substituir @option.token_git@ pelo token que se gera no próprio git lab. Precisa ter acesso de leitura e gravação.

git clone https://oauth2:@option.token_git@@git.url/repo/k8s.git

#Acessa a pasta K8S (repositorio)
cd k8s

#Configura usuário e e-mail, precisa ser de acordo com o token. Sem isso o commit não é aceito.
git config user.email "user@email.com"
git config user.name "User" 

echo "Preparando configurações...."

#Escreve o aquivo de configuração do K8S. Substitua @option.k8s_prod@ pelo token de acesso ao rancher. Precisa ter permissão de leitura no projeto a ser backupeado. Acesso nos config maps e secrets dos namespaces backupeados.

echo 'apiVersion: v1
kind: Config
clusters:
- name: "local"
  cluster:
    server: "https://@rancher_url@/k8s/clusters/local"

users:
- name: "local"
  user:
    token: "@option.k8s_prod@"


contexts:
- name: "local"
  context:
    user: "local"
    cluster: "local"

current-context: "local"' > /home/user/.kube/config

#Escreve a chave publica.

echo '-----BEGIN CERTIFICATE-----
MIIEzDCCArSgAwIBAgIQfQXRSiF6n65htcEaBMAYITANBgkqhkiG9w0BAQsFADAA
MB4XDTIyMDUxMzAxMjYzMloXDTMyMDUxMDAxMjYzMlowADCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBAMI3elwagCoTdtboj27PkvLRQ+ySZzGTnosRyaUe
0zqld+mHMowgGork0e+Fb2zTt0poGem//V0bw+mWKDZEE76QbVCLF/bsw4EemFGT
VFYhuypwNtMXTY6H6ZOp2gmCnqPrUG0WB03LdDzQf3pOZXa/2Rr6Ca2BQPwRY+5I
qzKZGe4hsV473HejmyWzN5AHGGU9Pc1szSU7bIegncsXEYc4UHr5wRLc77wdB+nR
ZxL6yE3oTHC9p7FQZe4qzBWJl8iWY1G158g0mi8odlHw/52RI0A2+lqAwl5t4+iR
KMtBcu6t9xpDYo2naSFJhtWO6pNcFHDx/9YVGO3i80+/ONirpjiXowFuirbMBTTo
K0Io/nvg3eG5zR5cgZy/fYMH4N1iBdljk9Wla6rA7rvz0zs4R9P8uXw19oqJODz9
I0rmjRv+FTYlZeqsmgga4nWei8pIDgzoB0KCsv4kZFlyuKftdxHKgSEiMNtU3bxU
aYIkDAvVpMoVqP7JQ3/Kuo8ETUBMdPP4t7le6noO9fg4HubZOCOTh8DCLo4TY8Y3
2/lEcQs5rJSF02SQDgF2DWlAEwa3nSk+cwwI/uKaNOyx3vcy8/1WyvoI/Aan1l0E
M7Ujc3fHT2tgU2f+jkLRwzEiXMzUUOy9dagthIc6LEpGHTXtjB9rAWInTr4vX4kD
dPOhAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIAATAPBgNVHRMBAf8EBTADAQH/MB0G
A1UdDgQWBBS1HCeXWnnCPaOTB5HpNZdIwqq5YjANBgkqhkiG9w0BAQsFAAOCAgEA
dHcwAq8+ikrEVx59NwYQHpk8XEspm/Gi/Tf3KDLGBxvpFXXkIY2hcVerJe9JS4ZK
iQA9BiTk/tWsIEJO+glsLGubQCqn0JpSUXawcHc5lluTzyylyvNB4yneBOMUwvgB
I++cZyH9v/8PeR/opEvdU2ud5OByWr7yY67oWl87IZCafZUoj9EBw11ByDy7gqh7
xIbmakoHmhe7nROXGi7ZUPmcMIf78H5aNNRyFX4Z6YD4hQggk0bKx7fHIqtyBP/7
JYsEAcxcgtUDjD2CTUdXI7eMu+3pDs7G2EJ/rlFF1BF55gAb4GckQuf28g1a+KpB
4TCT5Xe7/VSRf/hYOK6sgber3OVMSS4M2q5ILuSKzy6KVfWCXRUEIo1h+TbfykYb
Nctjd7ABDjFBTfrOmxWqVVfI8ALgCCEsQ14NQj4u9ZPGjqj+EQO91BscyryGvrtF
evXJHoXKaQcMkHdn1/dfdJjG1sHNPLOwVKyVlQvJFiQl2crlsdshEPZAzGF/EpgZ
YKNJbR8BhKEfdkP5CruyVNTPmPlDh/GItaRQEybnonwCPeB+J0DCCd8Em2T/94LR
IWohuNJ1kLUrD6eKmYxsm4YjkJ2skd45NqKduunWwPNRY/g3Cr24uuPIGWoBa5dR
I8v9AK2k7LMyYcsj/o5sjIRk/biPncPyq98qHsaWoF0=
-----END CERTIFICATE-----' >  secret.pem

#kubectl get namespace | grep sme- | awk '{print $1}' > _namespaces_

#Ponteiro do arquivo com os namespaces a serem backupeados.
file="_namespaces_"

echo "Namespaces mapeados..."

#Lista os namespaces no console
cat _namespaces_

echo "Inicio dos backups..."

#Para cada linha executa o kube-dump, para secrets e configmap. Os arquivos serão gerados dentro de uma pasta data.
lines=$(cat $file)
for line in $lines
do
  kube-dump ns -n $line -r secrets,configmap --kube-insecure-tls -s
  echo '.'
done

#Detele alguns arquivos não necessários.
echo "Deletando arquivos desnecessários..."
find . -name default-token* -delete
find . -name kube-root-ca* -delete
find . -name '*.yaml' -exec grep -i 'dockerconfigjson' {} \; -delete

#Escreve o nome de todos os arquivos to tipo secrets dentro de um arquivo.
find . -name *_secrets.yaml > _secrets_

echo "Secrets mapeados.."
cat _secrets_

#Novamente para cada linha do arquivo, no caso cada secret, efetua a criptografia com a chave publica.
echo "Criptografando..."
file="_secrets_"
lines=$(cat $file)
for line in $lines
do
  #se o arquivo de checksum existe, se valida se este ainda possui a mesma assinatura.
  if [ -f "$line.sha1" ]; then
    echo "$line.sha1 exists"
    if [ -z $(sha1sum --quiet -c $line.sha1) ]; then
      echo "$line não sofre modificação"
      rm -f $line
    #caso contrário, se utiliza o kubeseal para criptografar o secret no escopo do cluster. Arquivo gerado como .encrypt
    else
      echo "$line sofreu modificação, criptografando..."
      kubeseal --cert secret.pem --scope cluster-wide --format=yaml < $line > $line.encrypt
      #depois de criptograr o secret, se gera uma assinatura do secret.
      sha1sum $line > $line.sha1
      #depois de gerar a assinatura, se deleta o secret.
      rm -f $line
    fi
  #Caso o arquivo seja novo e não possua assinatura, se gera a assinatura, criptografa o secret e se apaga o secret.
  else
    sha1sum $line > $line.sha1
    cat $line.sha1
    kubeseal --cert secret.pem --scope cluster-wide --format=yaml < $line > $line.encrypt
    rm -f $line
  fi
done

#Conta-se o numero de arquivos do tipos *_secrets.yaml.
total=$(find . -name *_secrets.yaml | wc -l)

#Delete arquivos não necessários.
echo "deletando arquivos.."
rm -f _secrets_
rm -f secret.pem



#Caso não exista nenhum arquivo secret aberto, se faz o commit.
if [ $total -eq 0 ]; then
  git add .
  git commit -m "Commit automático.."
  echo "Commitando..."
  git push
else
  echo "Há secrets, abertos. Commit n pode ser feito. Verifique!"
fi

#Limpa configuração do acesso ao kubernetes.
echo "" > /home/user/.kube/config

cd ..

#Deleta pasta do repositório.
if [ -d "k8s" ]; then rm -Rf k8s; fi
