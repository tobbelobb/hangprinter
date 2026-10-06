"""Change filtering checks; generated sequences are not sensor training data."""
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from live_colour_feedback import ChangeFilter, Observation, observation


def sample(t, colour='Blue', margin=.8, valid=True):
    return Observation(t,colour,colour,margin,.1,3800,valid,19)


class ChangeTests(unittest.TestCase):
    def lock(self, state, start=0, colour='Blue'):
        event = None
        for i in range(5):
            result = state.update(sample(start+i*.03,colour))
            event = result or event
        return event

    def test_requires_time_and_sample_count(self):
        state = ChangeFilter()
        for i in range(4):
            self.assertIsNone(state.update(sample(i*.01)))
        self.assertIsNone(state.stable)
        self.assertEqual(state.update(sample(.11)),(None,'Blue'))
        self.assertEqual(state.changes,0)
        state = ChangeFilter(samples=5)
        for t in [0,.04,.08,.12]:
            self.assertIsNone(state.update(sample(t)))
        self.assertEqual(state.update(sample(.16)),(None,'Blue'))

    def test_blip_does_not_change_confirmed_colour(self):
        state = ChangeFilter()
        self.lock(state)
        state.update(sample(.15,'Yellow'))
        state.update(sample(.18,'Blue'))
        self.assertEqual(state.stable,'Blue')
        self.assertEqual(state.changes,0)
        self.assertEqual(self.lock(state,.21,'Yellow'),('Blue','Yellow'))
        self.assertEqual(state.changes,1)
        self.assertIsNone(state.update(sample(.39,'Yellow')))
        self.assertEqual(state.changes,1)

    def test_ambiguity_invalid_and_unknown_break_streak(self):
        for bad in [sample(.09,'Yellow',margin=.05), sample(.09,None), sample(.09,'Yellow',valid=False)]:
            state = ChangeFilter()
            for t in [0,.03,.06]:
                state.update(sample(t,'Yellow'))
            state.update(bad)
            for t in [.12,.15,.18]:
                self.assertIsNone(state.update(sample(t,'Yellow')))
            self.assertIsNone(state.stable)
            self.assertEqual(state.update(sample(.24,'Yellow')),(None,'Yellow'))

    def test_gap_reset_and_stale_state(self):
        state = ChangeFilter()
        self.lock(state)
        self.assertTrue(state.current(.3))
        self.assertFalse(state.current(.5))
        state.update(sample(.15,'Yellow'))
        state.update(sample(.18,'Yellow'))
        self.assertIsNone(state.update(sample(.8,'Yellow')))
        self.assertEqual(state.count,1)
        state.update(sample(.02,'Green'))  # Uno reset.
        self.assertIsNone(state.stable)
        self.assertEqual(state.changes,0)

    def test_recent_agreement_includes_rejected_readings(self):
        state = ChangeFilter()
        for t,c in [(0,'Blue'),(.03,None),(.06,'Blue'),(.09,'Yellow')]:
            state.update(sample(t,c))
        self.assertEqual(state.agreement('Blue'),.5)

    def test_parser_matches_known_centroid_and_rejects_wrong_model(self):
        model=json.loads((ROOT/'data/palette_2026-10-06_analysis/palette_model.json').read_text())
        cl=model['classes'][3]
        x=[m+c/inv if inv else m for m,c,inv in zip(model['mean'],cl['centroid'],model['inv_std'])]
        z=[(v-m)*inv for v,m,inv in zip(x,model['mean'],model['inv_std'])]
        d=[sum((v-c)**2 for v,c in zip(z,col['centroid'])) for col in model['classes']]
        others=sorted(d)[1]
        row=dict(valid='1',normalization='1',nearest_id='3',class_id='3',
                 R_Hz=str(x[0]*10000),G_Hz=str(x[1]*10000),B_Hz=str(x[2]*10000),
                 C_Hz='3800',scale_pct='100',settled='1',clear100_Hz='3800',
                 margin=str((others-d[3])/others),distance2=str(d[3]),t_ms='100',scan_us='19000')
        self.assertEqual(observation(row,model).colour,'Blue')
        row['normalization']='0'
        with self.assertRaisesRegex(ValueError,'normalization'):
            observation(row,model)
        row['normalization']='1'
        row['distance2']='99'
        with self.assertRaisesRegex(ValueError,'centroids'):
            observation(row,model)
        row.update(valid='0',nearest_id='-1',class_id='-1',margin='0',distance2='-1',C_Hz='0',clear100_Hz='0')
        self.assertFalse(observation(row,model).valid)


if __name__=='__main__':
    unittest.main()
