
#
# Specifying fugit
#
# Mon Jan  2 11:17:40 JST 2017  Ishinomaki
#

require 'spec_helper'


describe Fugit::Cron do

  NOW = Time.parse('2017-01-02 12:00:00')

  NEXT_TIMES = [

    # min hou dom mon dow, expected next time[, now]

    [ '5 0 * * *', '2017-01-03 00:05:00' ],
    [ '15 14 1 * *', '2017-02-01 14:15:00' ],

    [ '0 0 1 1 *', '2018-01-01 00:00:00' ],
    [ '* * 29 * *', '2017-01-29 00:00:00' ],
    [ '* * 29 * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * L * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * last * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '* * -1 * *', '2016-02-29 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-26 00:00:00', '2016-02-01' ],
    [ '0 0 -4,-3 * *', '2016-02-27 00:00:00', '2016-02-26 12:00' ],

    [ '* * * * sun', '2017-01-8' ],

    [ '* * -2 * *', '2017-01-30' ],

    [ '* * * * mon#2', '2017-01-09' ],
    [ '* * * * mon#-1', '2017-01-30' ],
    [ '* * * * tue#L', '2017-01-31' ],
    [ '* * * * tue#last', '2017-01-31' ],
    [ '* * * * mon#2,tue', '2016-12-06', '2016-12-01' ],
    [ '* * * * mon#2,tue', '2016-12-12', '2016-12-07' ],

    [ '0 0 * * mon#2,tue', '2017-01-09', '2017-01-06' ],
    [ '0 0 * * mon#2,tue', '2017-01-31', '2017-01-30' ],

    [ '00 24 * * *', '2017-01-02', '2017-01-01 12:00' ],

    # Note: The day of a command's execution can be specified by two fields
    # -- day of month, and day of week.
    # If both fields are restricted (ie, are not *), the command will be run
    # when either field matches the current time.  For example,
    # ``30 4 1,15 * 5'' would cause a command to be run at 4:30 am on the
    # 1st and 15th of each month, plus every Friday.
    #
    # Thanks to Dominik Sander for pointing to that in
    # https://github.com/jmettraux/rufus-scheduler/pull/226

    [ '30 04 1,15 * 5', '2017-01-06 04:30:00', '2017-01-03' ],
    [ '30 04 1,15 * 5', '2017-01-15 04:30:00', '2017-01-14' ],
    [ '30 04 1,15 * 5', '2017-01-20 04:30:00', '2017-01-16' ],
  ]

  describe '#next_time' do

    success =
      proc { |cron, next_time, now|

        it "succeeds #{cron.inspect} -> #{next_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ent = Time.parse(next_time)
          now = Time.parse(now) if now

          nt = c.next_time(now || NOW)

          expect(
            Fugit.time_to_plain_s(nt)
          ).to eq(
            Fugit.time_to_plain_s(ent)
          )
        end
      }

    NEXT_TIMES.each(&success)
  end

  describe '#match?' do

    success =
      proc { |cron, next_time, _|

        it "succeeds #{cron.inspect} ? #{next_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ent = Time.parse(next_time)

          expect(c.match?(ent)).to be(true)
        end
      }

    NEXT_TIMES.each(&success)
  end

  PREVIOUS_TIMES = [

    [ '5 0 * * *', '2016-12-31 00:05:00', '2017-01-01' ],
    [ '5 0 * * *', '2017-01-13 00:05:00', '2017-01-14' ],

    [ '0 0 1 1 *', '2017-01-01 00:00:00', '2017-03-15' ],
    [ '0 12 1 1 *', '2016-01-01 12:00:00', '2017-01-01' ],

    [ '* * 29 * *', '2017-01-29 23:59:00', '2017-03-15' ],
    [ '* * 29 * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * L * *', '2017-02-28 23:59:00', '2017-03-15' ],
    [ '* * L * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * last * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '* * -1 * *', '2016-02-29 23:59:00', '2016-03-15' ],
    [ '0 0 -4,-3 * *', '2017-02-26 00:00:00', '2017-03-15' ],
    [ '0 0 -4,-3 * *', '2017-02-25 00:00:00', '2017-02-25 23:00' ],
    [ '* * * * sun', '2017-01-29 23:59:00', '2017-01-31' ],
    [ '* * * * mon#2', '2017-01-09 23:59:00', '2017-01-31' ],
    [ '* * * * mon#-1', '2017-01-30 23:59:00', '2017-01-31' ],
    [ '* * * * wed#L', '2017-01-25 23:59:00', '2017-01-31' ],
    [ '* * * * wed#last', '2017-01-25 23:59:00', '2017-01-31' ],
    [ '* * * * mon#2,tue', '2017-01-24 23:59:00', '2017-01-30' ],
    [ '* * * * mon#2,wed', '2017-01-09 23:59:00', '2017-01-10' ],
    [ '30 04 1,15 * 5', '2017-01-15 04:30:00', '2017-01-16' ],
    [ '30 04 1,15 * 5', '2017-01-13 04:30:00', '2017-01-15' ],

    [ '00 24 * * *', '2017-01-02', '2017-01-02 12:00' ],

    [ '0 0 * * mon#2,tue', '2017-01-09', '2017-01-09 12:00' ],
    [ '0 0 * * mon#2,tue', '2017-01-03', '2017-01-04' ],
  ]

  describe '#previous_time' do

    success =
      proc { |cron, previous_time, now|

        now = now ? Time.parse(now) : NOW

        it "succeeds #{cron.inspect} #{now} -> #{previous_time.inspect}" do

          c = Fugit::Cron.parse(cron)
          ept = Time.parse(previous_time)

          pt = c.previous_time(now)

          expect(
            Fugit.time_to_plain_s(pt)
          ).to eq(
            Fugit.time_to_plain_s(ept)
          )

          expect(c.match?(ept)).to eq(true) # quick check
        end
      }

    PREVIOUS_TIMES.each(&success)
  end

  describe '#frequency' do

    [
      [ '* * * * *', [ 60, 60, 525600 ] ],
      [ '0 0 * * *', [ 86400, 86400, 365 ] ],
      [ '0 0 * * sun', [ 604800, 604800, 53 ] ],
    ].each do |cron, freq|

      it "computes #{freq.inspect} for #{cron.inspect}" do

        expect(Fugit::Cron.parse(cron).frequency).to eq(freq)
      end
    end

    it 'accepts a year argument' do

      expect(
        Fugit::Cron.parse('0 0 * * sun').frequency(2016)
      ).to eq(
        [ 604800, 604800, 52 ]
      )
    end
  end

  describe '.parse' do

    it 'parses @reboot'

    context 'success' do

      success =
        proc { |cron, expected|
          it "parses #{cron}" do
            c = Fugit::Cron.parse(cron)
            expect(c.to_cron_s).to eq(expected)
          end
        }

      [

        [ '@yearly', '0 0 1 1 *' ],
        [ '@annually', '0 0 1 1 *' ],
        [ '@monthly', '0 0 1 * *' ],
        [ '@weekly', '0 0 * * 0' ],
        [ '@daily', '0 0 * * *' ],
        [ '@midnight', '0 0 * * *' ],
        [ '@hourly', '0 * * * *' ],

        [ '5 0 * * *', '5 0 * * *' ],
          # 5 minutes after midnight, every day
        [ '15 14 1 * *', '15 14 1 * *' ],
          # at 1415 on the 1st of every month
        [ '0 22 * * 1-5', '0 22 * * 1,2,3,4,5' ],
          # at 2200 on weekdays
        [ '23 0-23/2 * * *', '23 0,2,4,6,8,10,12,14,16,18,20,22 * * *' ],
          # 23 minutes after midnight, 0200, 0400, ...
        #[ '5 4 * * sun', :xxx ],
          # 0405 every sunday

        [ '14,24 8-12,14-19/2 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],
        [ '24,14 14-19/2,8-12 * * *', '14,24 8,9,10,11,12,14,16,18 * * *' ],

        [ '*/1 1-3/1 * * *', '* 1,2,3 * * *' ],

        [ '0 22 * * 5-1', '0 22 * * 1,2,3,4,5' ],

      ].each(&success)

      context 'negative monthdays' do

        [
          [ '* * -1 * *', '* * -1 * *' ],
          [ '* * -7--1 * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * -1--7 * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * -7--1/2 * *', '* * -7,-5,-3,-1 * *' ],
          [ '* * L * *', '* * -1 * *' ],
          [ '* * -7-L * *', '* * -7,-6,-5,-4,-3,-2,-1 * *' ],
          [ '* * last * *', '* * -1 * *' ],
        ].each(&success)
      end

      context 'months' do

        [
          [ '* * * jan-mar *', '* * * 1,2,3 *' ],
          [ '* * * Jan-Aug/2 *', '* * * 1,3,5,7 *' ],
        ].each(&success)
      end

      context 'weekdays' do

        [
          [ '* * * * sun,mon', '* * * * 0,1' ],
          [ '* * * * Sun,mOn', '* * * * 0,1' ],
          [ '* * * * mon-wed', '* * * * 1,2,3' ],
          [ '* * * * sun,2-4', '* * * * 0,2,3,4' ],
          [ '* * * * sun,mon-tue', '* * * * 0,1,2' ],
          [ '* * * * sun,Sun,0,7', '* * * * 0' ],
#a_eq '0 0 * * mon#1,tue', [[0], [0], [0], nil, nil, [2], ["1#1"]]
        ].each(&success)
      end

      context 'weekdays #' do

        [
          [ '0 0 * * mon#1,tue', '0 0 * * 1#1,2' ],
          [ '0 0 * * mon#-1,tue', '0 0 * * 1#-1,2' ],
          [ '0 0 * * mon#L,tue', '0 0 * * 1#-1,2' ],
          [ '0 0 * * mon#last,tue', '0 0 * * 1#-1,2' ],
        ].each(&success)
      end
    end

    context 'failure' do

      [
        '* 25 * * *',
        '* * -32 * *'
      ].each do |cron|

        it "returns nil for #{cron}" do

          expect(Fugit::Cron.parse(cron)).to eq(nil)
        end
      end
    end
  end

  describe '.do_parse' do

    [
      '* 25 * * *',
      '* * -32 * *'
    ].each do |cron|

      it "raises for #{cron}" do
        expect {
          Fugit::Cron.do_parse(cron)
        }.to raise_error(
          ArgumentError, "not a cron string #{cron.inspect}"
        )
      end
    end
  end

  describe '#==' do

    it 'returns true when equal' do

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * * * *')
      ).to eq(true)

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * */1 * *')
      ).to eq(true)
    end

    it 'returns false else' do

      expect(
        Fugit::Cron.parse('* * * * *') ==
        Fugit::Cron.parse('* * * * 1')
      ).to eq(false)

      expect(
        Fugit::Cron.parse('* * * * *') !=
        Fugit::Cron.parse('* * * * 1')
      ).to eq(true)

      expect(Fugit::Cron.parse('* * * * *') == 1).to eq(false)
    end
  end
end

