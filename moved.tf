# The standalone Cast AI helm_releases got a `count` added so they can be
# replaced by the Cast AI Umbrella Helm release (var.umbrella_enabled).
# These moved blocks preserve existing state addresses so enabling the
# umbrella chart (or not) doesn't cause drift for existing users.
moved {
  from = helm_release.castai_agent
  to   = helm_release.castai_agent[0]
}

moved {
  from = helm_release.castai_evictor_ext
  to   = helm_release.castai_evictor_ext[0]
}

moved {
  from = helm_release.castai_spot_handler
  to   = helm_release.castai_spot_handler[0]
}

moved {
  from = helm_release.castai_live
  to   = helm_release.castai_live[0]
}
