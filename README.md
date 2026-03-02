# Endroll Video Encoding Infrastructure

Azure上に構築された、GPU（NVIDIA T4）を活用したビデオエンコーディング用Windows環境のInfrastructure as Code (IaC) リポジトリ。

## 構成概要

以下のTerraformリソースをデプロイする。

- **Virtual Machine**: Windows 11 (24H2 Pro)
- **Compute Size**: Standard NC4as_T4_v3 (NVIDIA Tesla T4 GPU搭載)
- **Networking**:
  - 静的パブリックIPとカスタムDNS名（`<dns_name>.japaneast.cloudapp.azure.com`）を付与。
  - RDP (3389, 8080) および WinRM (5986) ポートを開放。
- **GPU Driver**: NVIDIA GRID Driver (vGPU)
  - エンコード機能 (NVENC) に最適化されたドライバーを自動インストールする。
- **Storage**: Azure Files
  - `encoded-videos` 共有をVM起動時に **Z: ドライブ** として自動マウントする。
- **Auto Management**:
  - **自動シャットダウン**: 毎日 23:00 JST に自動停止し、不要なコストを抑制。
  - **予算管理**: 100,000円を上限とする月次予算アラート（30%, 50%, 100%到達時にメール通知）。

## 使い方

### 1. 事前準備

- Azure CLI のインストールとログイン (`az login`)
- Terraform (v1.0+) のインストール

### 2. 設定のカスタマイズ

`terraform/terraform.tfvars` を開き、必要に応じて各項目を変更する。

```hcl
dns_name     = "your-unique-dns-name"
alert_emails = ["your-email@example.com"]
location     = "japaneast"
vm_size      = "Standard_NC4as_T4_v3"
```

### 3. デプロイ

```bash
cd terraform
terraform init
terraform apply
```

完了後、パブリックIPとFQDN（DNS名）が出力される。

### 4. 接続

- **情報の確認**: パブリックIPやSMBパスなどは、デプロイ完了時にコンソールに出力される。管理者パスワードなどの `sensitive` な値を含むすべての出力を確認するには、以下のコマンドを実行する。
  ```bash
  # 全出力の確認（sensitiveな値も表示）
  terraform output -json

  # 特定の値のみを直接表示
  terraform output -raw admin_password
  ```
- **RDP**: 出力された FQDN に対してリモートデスクトップ接続を行う。
- **Azure Files**: VM内の Z: ドライブに直接ファイルを保存。複数のVMやPCからSMB経由でアクセス可能。

## Ansible による構築

Terraform で VM を作成した後、以下のコマンドを実行して OS 内部の設定を行う。
`inventory.yml` は Terraform によって自動生成されるため、追加の引数は不要。

```bash
cd ansible
ansible-playbook -i inventory.yml playbook.yml
```

### Ansible で実行される内容
- タイムゾーンの設定 (JST)
- 日本語言語パックのインストールと設定
- RDP ポートの変更 (3389 -> 8080)
- Azure Files の Z: ドライブへのマウント
- Windows Update の実行

## 注意事項

- **コスト**: GPU搭載VMは単価が高いため、使用しない時間は必ず停止を確認すること（自動シャットダウン設定済み）。
- **WinRM**: Ansible等の自動化ツール用に WinRM を HTTPS (5986) で構成済み。
