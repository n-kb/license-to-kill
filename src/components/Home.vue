<template>
  <div>
    <navbar></navbar>
    <section class="section">
      <div class="container is-fluid">
        <div class="columns">
          <div class="column is-2 is-offset-10">
            <shareitem :title="$t('License to Kill')" :shareText="$t('Share')" :description="$t('lede')"></shareitem>
          </div>
        </div>
        <div class="columns">
          <div class="column is-half is-offset-one-quarter">
            <div class="content">
              <h1 class="title is-1 has-text-centered is-size-3-mobile">{{ $t('License to Kill') }}</h1>
              <div class="columns">
                <div class="column has-text-centered">
                  <p>
                    <a v-if="$i18n.locale == 'en'" @click="changeLocale('de')">Auf Deutsch lesen: Lizenz zum Töten</a>
                    <a v-if="$i18n.locale == 'de'" @click="changeLocale('en')">Read in English: License to Kill</a>
                  </p>
                </div>
              </div>
              <div class="columns">
                <div class="column has-text-centered">
                  <p class="byline">{{ $t("An interactive database by") }} <strong><a href="https://blog.nkb.fr" class="byline--link">Nicolas Kayser-Bril</a></strong></p>
                </div>
                <div class="column byline has-text-centered">
                  <p class="byline">{{ $t("20 September 2018") }}</p>
                </div>
              </div>
              <div class="article-content">
                <p class="lede">{{ $t("lede") }}</p>
                <hr/>
                <p v-for="(kill, index) in kills_summaries" class="kill-summary" v-if="index <= current_kill_index" v-html="kill"></p>
                <p class="has-text-centered" v-if="current_kill_index < kills_summaries.length">
                  <a class="button is-primary" @click="current_kill_index++">{{ $t("Show another case") }}</a>
                </p>
                <p>{{ $t("intro1", {pedestrians: victims["pedestrian"], cyclists: victims["cyclist"], total: victims["pedestrian"] + victims["cyclist"]  }) }}</p>
                <p>{{ $t("intro2") }}</p>
                <p>{{ $t("intro3", { total: victims["pedestrian"] + victims["cyclist"] }) }}</p>
                <ul class="no-bullets">
                  <li>
                    <span class="yellow kill-dot">
                      •
                    </span> {{ $t("means that the homicide is documented.") }}
                  </li>
                  <li>
                    <span class="blue kill-dot">
                      •
                    </span> {{ $t("means that a trial took place.") }}
                  </li>
                  <li>
                    <span class="grey kill-dot">
                      •
                    </span> {{ $t("means I could not find documentation for this homicide.") }} 
                  </li>
                </ul>
                <p class="is-size-6" v-html="$t('contactMe')"></p>
                <viz :kills="kills" :stats="stats"/>
                <h2>{{ $t("Blaming the victims") }}</h2>
                <p v-html="$t('para1')">
                </p>
                <p v-html="$t('para2')">
                </p>
                <p v-html="$t('para3')">
                </p>
                <h2>{{ $t("Attempted murder") }}</h2>
                <p v-html="$t('para4')">
                </p>
                <p v-html="$t('para5')">
                </p>
                <p v-html="$t('para6')">
                </p>
                <p v-html="$t('para7')">
                </p>
                <article class='message is-link' id='newsletter'>
                  <div class='message-header'>
                    <p>{{ $t("Newsletter") }}</p>
                  </div>
                  <div class='message-body'>
                    <p>{{ $t("newsletter1") }}</p>
                    <form style='padding:3px;' action='https://tinyletter.com/nkb' method='post' target='popupwindow' onsubmit="window.open('https://tinyletter.com/nkb', 'popupwindow', 'scrollbars=yes,width=800,height=600');return true">
                      <p>
                        <input type='text' style='width:300px' :placeholder='$t("Your e-mail address here")' name='email' id='tlemail' class='input'/>
                      </p>
                      <input type='hidden' value='1' name='embed'/>
                      <input type='submit' :value='$t("Submit")' class='button is-link' />
                    </form>
                  </div>
                </article>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
  import navbar from './Navbar.vue'
  import shareitem from './shareItem.vue'
  import viz from './viz.vue'
  import moment from 'moment'
  import kills_csv from '../assets/kills.csv'
  import stats_csv from '../assets/stats.csv'
  export default {
    name: 'Home',
    data () {
      return {
        current_kill_index: 0,
        kills_summaries: [],
        victims: {"cyclist": 0, "pedestrian": 0},
        kills: [],
        stats: []
      }
    },
    components: {
      navbar,
      shareitem,
      viz
    },
    methods: {
      changeLocale(lang) {
        this.$i18n.locale = lang
        moment.locale(lang)
        document.title = this.$t('License to Kill')
        this.makeSummaries()
        var original_location = window.location
        if (window.location.toString().indexOf("?") != -1) {
          var pos = window.location.toString().indexOf("?")
          original_location = window.location.toString().substring(0,pos)
        }
        window.history.pushState({}, "", original_location + "?lg=" + lang);
      },
      makeSummaries () {
        var kills_summaries_count = 0
        for (var i=0; i < this.kills.length; i++) {
          this.kills[i]["long_summary"] = this.makeSummary(this.kills[i])
          if (this.kills[i]["date_trial"] != null) {
            this.$set(this.kills_summaries, kills_summaries_count, this.kills[i]["long_summary"])
            kills_summaries_count++
          }
        }
      },
      makeSummary (kill) {
        var date = moment(kill.date, "YYYY-MM-DD").format("MMMM YYYY")
        
        // Killer name block
        var killer_name = ""
        if (kill.killer_gender == "M" && kill.killer_age != null) {
          killer_name = this.$t("summary.killer.male-age", {age: kill.killer_age})
        } else if (kill.killer_gender == "F" && kill.killer_age != null) {
          killer_name = this.$t("summary.killer.female-age", {age: kill.killer_age})
        }
        if (kill.killer_name != null) {
          killer_name = kill.killer_name + ", "  + killer_name + ","
        }
        if (kill.killer_name != null && kill.killer_age == null) {
          killer_name = kill.killer_name
        }

        // Victim name block
        var victim_name = ""
        if (kill.victim_gender == "M" && kill.victim_age != null) {
          victim_name = this.$t("summary.victim.male-age-" + kill.victim_type, {age: kill.victim_age})
        } else if (kill.victim_gender == "F" && kill.victim_age != null) {
          victim_name = this.$t("summary.victim.female-age-" + kill.victim_type, {age: kill.victim_age})
        } else if (kill.victim_gender == "F" && kill.victim_age == null) {
          victim_name = this.$t("summary.victim.female-" + kill.victim_type)
        } else if (kill.victim_gender == "M" && kill.victim_age == null) {
          victim_name = this.$t("summary.victim.male-" + kill.victim_type)
        }
        if (kill.victim_name != null) {
          victim_name = kill.victim_name + ", "  + victim_name
        }

        // Car model
        var car_model = ""
        if (kill.weapon != null){
          if (kill.weapon == "LKW") { car_model += this.$t("using a truck") }
          else if (kill.weapon == "taxi") { car_model += this.$t("using a taxi") }
          else if (kill.weapon == "bus") { car_model += this.$t("using a bus") }
          else if (kill.weapon == "reisebus") { car_model += this.$t("using a travel bus")}
          else if (kill.weapon == "motorrad") { car_model += this.$t("using a motor bike") }
          else { car_model += this.$t("using a", {weapon: kill.weapon}) }
        }

        var desc = this.$t("in-date", {date: date})

        if (kill.bezirk != null){
          desc += this.$t("in-location", {ort:kill.bezirk})
        }

        desc += this.$t("killed", {killer:killer_name, victim:victim_name })

        if (car_model != null) {
          desc += car_model
        }

        // Punishment
        if (kill.date_trial != null) {
          desc += "</p><p>"
          // Trial date
          var date_diff = moment(kill.date_trial, "YYYY-MM-DD").diff(moment(kill.date, "YYYY-MM-DD"), "months")
          desc += this.$t("months-later", {date_diff:date_diff})

          // Prison time
          if (kill.sentence_months != null) {
            desc += this.$t("months-prison", {duration:kill.sentence_months})

            if (kill.suspended_sentence_months != null) {
              desc += this.$t("months-suspended", {duration:kill.suspended_sentence_months})
            }
            if (kill.fine_penal != null) {
              desc += this.$t("fine", {fine:Number(kill.fine_penal).toLocaleString(this.$i18n.locale)})
            }

          // Suspended sentence only
          } else if (kill.suspended_sentence_months != null) {
            desc += this.$t("months-suspended2", {duration:kill.suspended_sentence_months})
            if (kill.fine_penal != null) {
              desc += this.$t("fine2", {fine:Number(kill.fine_penal).toLocaleString(this.$i18n.locale)})
            }
          }

          // Fine only
          else if (kill.fine_penal != null) {
            desc += this.$t("fine3", {fine:Number(kill.fine_penal).toLocaleString(this.$i18n.locale)})
          }

          // Civil fine
          if (kill.fine_civil != null) {
            desc += this.$t("fine-civil", {fine:kill.fine_civil.toLocaleString(this.$i18n.locale)})
          }

          desc += this.$t("fine-end")
        }

        if (kill.summary_en != null && this.$i18n.locale == "en") {
          desc += " " + kill.summary_en
        } else if (kill.summary_de != null && this.$i18n.locale == "de") {
          desc += " " + kill.summary_de
        }

        return desc
      }
    },
    created () {

      this.kills = kills_csv

      // Sets locale from URL GET var
      if (document.location.toString().indexOf('lg=') != -1) {
        var pos = document.location.toString().indexOf('lg=')
        var lang = document.location.toString().substring(pos+3, pos+5)
        this.changeLocale(lang)
      } else {
        this.changeLocale("en")
      }
      
      // Fetches stats
      this.stats = stats_csv
      // Counts the number of victims
      for(var j = 0; j <= 2018 - 2008; j++) {
        this.victims["pedestrian"] += Number(this.stats[j]["pedestrian"])
        this.victims["cyclist"] += Number(this.stats[j]["cyclist"])
      }
      // Discounts for cyclists and pedestrians causing accidents or falling down
      this.victims["pedestrian"] = Math.floor(this.victims["pedestrian"] * .9 / 10) * 10
      this.victims["cyclist"] = Math.floor(this.victims["cyclist"] * .9 / 10) * 10
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="sass">
@import "colors.sass"
$family-primary: "Arial"
$title-size: 2.5em
$weight-semibold: 200
$body-family: "Arial"
$primary: $nkb-purple
$info: $nkb-lightblue
$link: $nkb-darkblue

@import "~bulma/bulma"

h1
  font-weight: 200

.lede
  font-weight: bold

.kill-summary
  border-bottom: 0.5px dotted lighten($nkb-darkblue, 60%)

.kill-dot
  font-size: 1.6rem
  font-weight: bold

.yellow
  color: $nkb-yellow

.blue
  color: $nkb-darkblue

.grey
  color: #ddd

.article-content
  font-size: 1.2rem
  line-height: 2rem
  font-family: Georgia

.byline
  font-variant: small-caps
  font-size: .8rem
  font-family: Georgia

.no-bullets
  list-style-type: none !important
</style>
