```bash
cp backend.conf.default backend.conf
cp variables.env.default variables.env
```

```bash
export $(cat variables.env | xargs)
```

```bash
packer build  \
    -var token=$TF_VAR_token \
    -var folder_id=$TF_VAR_folder_id \
    -var subnet_id=$TF_VAR_subnet_id \
    packer.json
```

```bash
terraform apply
```

![diagram] (graph.svg)