# syntax=docker/dockerfile:1
FROM plone/frontend-builder:18 AS builder

# Build Volto Project and then remove directories not needed for production
COPY pnpm-workspace.yaml /app/
RUN --mount=type=cache,id=pnpm,target=/app/.pnpm-store,uid=1000 <<EOT
    set -e
    pnpm build
    ( cd /app/core/packages/volto && pnpm install @eeacms/volto-industry-theme )
    rm -rf node_modules
    pnpm install --prod
EOT

FROM plone/frontend-prod-config:18 AS base

LABEL maintainer="Plone Community <dev@plone.org>" \
    org.label-schema.name="plone-frontend" \
    org.label-schema.description="Plone frontend image" \
    org.label-schema.vendor="Plone Foundation"

# Copy Volto project
COPY --from=builder /app/ /app/