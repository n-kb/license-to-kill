<template>
  <div class="position-absolute">
    <div class="has-text-right" v-if="!showShare">
      <span class="icon">
        <i class="fas fa-share"></i>
      </span>
      <span class="is-size-7 is-uppercase">
        <a @click="showShare=true">
          {{ shareText }}
        </a>
      </span>
    </div>
    <div class="card share-card" v-if="showShare">
      <div class="card-content">
        <div class="content">
          <div class="columns zero-space">
            <div class="column is-offset-10 zero-space has-text-right">
              <a class="card-header-icon zero-space close-button" @click="showShare=false">
                <span class="icon">
                  <i class="fas fa-window-close"></i>
                </span>
              </a>
            </div>
          </div>
          <social-sharing :url="url"
                      :title="title"
                      :description="description"
                      twitter-user="nicolaskb"
                      inline-template>
            <div>
              <div class="columns">
                <div class="column is-half no-padding">
                  <a>
                    <network network="email">
                        <i class="fa fa-envelope"></i> <span class="is-size-7">&nbsp;Email</span>
                    </network>
                  </a>
                </div>
                <div class="column is-half no-padding">
                  <a>
                    <network network="facebook">
                        <i class="fab fa-facebook"></i> <span class="is-size-7">&nbsp;Share</span>
                    </network>
                  </a>
                </div>
              </div>
              <div class="columns">
                <div class="column is-half no-padding">
                  <a>
                    <network network="twitter">
                        <i class="fab fa-twitter"></i> <span class="is-size-7">&nbsp;Tweet</span>
                    </network>
                  </a>
                </div>
                <div class="column is-half no-padding">
                  <a>
                    <network network="linkedin">
                        <i class="fab fa-linkedin"></i> <span class="is-size-7">&nbsp;Linkedin</span>
                    </network>
                  </a>
                </div>
              </div>
              <div class="columns">
                <div class="column is-half no-padding">
                  <a>
                    <network network="reddit">
                        <i class="fab fa-reddit"></i> <span class="is-size-7">&nbsp;Reddit</span>
                    </network>
                  </a>
                </div>
              </div>
            </div>
          </social-sharing>
          <hr>
          <div>
            <span class="is-size-7">
              Permalink
            </span>
            <input class="input is-small" readonly :value="url">
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

var SocialSharing = require('vue-social-sharing');

export default {
  name: 'shareitem',
  data(){
    return {
      showShare: false,
      url: String(window.location)
    }
  },
  components: {
    SocialSharing
  },
  props: {
    title: {
      default: "",
      type: String
    },
    description: {
      default: "",
      type: String
    },
    shareText: {
      default: "",
      type: String
    }
  }

}
</script>

<style lang="sass">

.zero-space
  margin: 0 0 .2rem !important
  padding: 0 !important

.position-absolute
  position: absolute

.close-button
  justify-content: end;
  display: inline !important

.no-padding
  padding: 0
</style>
