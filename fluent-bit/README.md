# Setup

1. from the fluent bit directory run `helm dependency build`
2. then from the root directory of the project run `helm upgrade --install -f ./fluent-bit/values.yaml fluent-bit ./fluent-bit -n shp`