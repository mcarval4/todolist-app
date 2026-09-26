# Cross-Repository Automation

The application repository builds, signs and publishes the TodoList image. It does not deploy to
Kubernetes. `Build And Propose Release` creates a short-lived GitHub App installation token and
uses it only to open a pull request in `mcarval4/todolist-gitops`.

The GitHub App must be installed on `todolist-app` and `todolist-gitops` with the minimum
permissions below:

| Repository | Permission | Access |
|---|---|---|
| `todolist-app` | Contents | Read and write for the later release tag workflow |
| `todolist-gitops` | Contents, pull requests | Read and write to create a promotion PR |

Configure the following Actions secrets in `todolist-app`:

- `TODOLIST_AUTOMATION_APP_ID`
- `TODOLIST_AUTOMATION_APP_PRIVATE_KEY`

The private key is stored only as a GitHub Actions secret. It must not be copied to `.env`,
Terraform state, Git history or deployment evidence.

Configure the same two secrets in `todolist-gitops`. After the local GitOps workflow has passed
smoke, HA and RBAC checks, it sends a repository dispatch to `todolist-app`. The
`Release Validated Application` workflow then tags the source revision supplied by the promotion
metadata and creates the GitHub Release there.
