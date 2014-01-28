#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Author: AxiaCore S.A.S. http://axiacore.com
"""
You can safely execute it like this, make sure you have installed jira-python:

    python -c "$(curl -fsSL https://raw.github.com/AxiaCore/axiacore_utils/master/jira/axiajira.py)" --username=?? --password=?? --date=??

"""
import getpass
import optparse
import json

from time import strptime
from datetime import date

from jira.client import JIRA


def parse_params():
    parser = optparse.OptionParser()
    parser.add_option(
        '-d',
        '--date',
        dest='date_',
        help=u'Fecha para la que se desea obtener el reporte '
        u'(formato yyyy-mm-dd), el día de hoy si no se especifica.',
        action="store",
        type="string",
    )
    parser.add_option(
        '-u',
        '--username',
        dest='username',
        help=u'Usuario con el cual conectarse a JIRA',
        action="store",
        type="string",
    )
    parser.add_option(
        '-w',
        '--password',
        dest='password',
        help=u'Contraseña para acceder a JIRA',
        action="store",
        type="string",
    )
    parser.add_option(
        '-l',
        '--user_list',
        dest='user_list',
        help=u'Usuarios para conteo separados por coma',
        action="store",
        type="string",
    )
    parser.add_option(
        '-q',
        '--quiet',
        dest='verbose',
        help=u'Use esta opción para ver resultados globales únicamente',
        action="store_false",
        default=True,
    )
    parser.add_option(
        '-j',
        '--json',
        dest='format_json',
        help=u'Use esta opción para ver resultados en json',
        action="store_true",
        default=False,
    )
    parser.add_option(
        '-f',
        '--keyfile',
        dest='keyfile',
        help=u'Llave privada RSA1 (.pem)',
        action="store",
        type="string",
    )
    parser.add_option(
        '-k',
        '--key',
        dest='consumerkey',
        help=u'Consumer Key para OAuth',
        action="store",
        type="string",
    )
    parser.add_option(
        '-t',
        '--token',
        dest='accesstoken',
        help=u'Access Token para OAuth',
        action="store",
        type="string",
    )
    parser.add_option(
        '-s',
        '--secret',
        dest='accesstokensecret',
        help=u'Access Token Secret para OAuth',
        action="store",
        type="string",
    )
    options, _ = parser.parse_args()
    oauth_options_enabled = [ o is not None for o in [
        options.keyfile,
        options.consumerkey,
        options.accesstoken,
        options.accesstokensecret,
    ]]
    if options.username is None and not all(oauth_options_enabled):
        parser.print_help()
        parser.error('Por favor especifique todas las credenciales para autenticación oauth -f -k -t -s')
    elif options.username and any(oauth_options_enabled):
        parser.print_help()
        parser.error('Por favor especifique únicamente usuario o de forma excluyente las opciones oauth -f -k -t -s')
    options.is_oauth = True
    if options.username:
        options.is_oauth = False
    try:
        strptime(options.date_, '%Y-%m-%d')
    except ValueError:
        parser.error(u'Fecha inválida: {}'.format(options.date_))
    except TypeError:
        options.date_ = date.today()
    if options.keyfile:
        try:
            with open(options.keyfile,  'r') as key_cert_file:
                key_cert_data = key_cert_file.read()
            options.key_cert_data = key_cert_data
        except IOError:
           print 'Oh dear.'
    return options


def main():
    options = {
        'server': 'https://axiacore.atlassian.net'
    }
    args = parse_params()

    if args.user_list:
        user_list = args.user_list.split(u',')
    else:
        user_list = []
    verbose = args.verbose
    simple = args.format_json
    if simple:
        verbose = False
    if args.is_oauth:
        oauth_dict = {
            'access_token': args.accesstoken,
            'access_token_secret': args.accesstokensecret,
            'consumer_key': args.consumerkey,
            'key_cert': args.key_cert_data,
        }
        jira = JIRA(oauth=oauth_dict, options=options)
    else:
        if args.password is None:
            args.password = getpass.getpass()
        jira = JIRA(basic_auth=(args.username, args.password), options=options)

    eval_date = args.date_

    qa_returned = 0
    qa_total = 0
    review_returned = 0
    review_total = 0
    points_at_axiacore = 0
    points_to_count = 0.0

    points_per_person = {}
    done_issues_query = (
        'project = "%s" AND status CHANGED '
        'FROM "Quality Assurance" TO Review ON "%s" '
        'AND "Story Points" IS NOT NULL'
    )
    qa_issues_query = (
        'project = "%s" AND status WAS "Quality Assurance" ON "%s" '
        'AND "Story Points" IS NOT NULL'
    )
    qa_returned_issues_query = (
        'project = "%s" AND status CHANGED '
        'FROM "Quality Assurance" TO "Stopped" ON "%s" '
        'and "Story Points" IS NOT NULL'
    )
    review_issues_query = (
        'project = "%s" AND status WAS "Review" ON "%s" '
        'AND "Story Points" IS NOT NULL'
    )
    review_returned_issues_query = (
        'project = "%s" AND status CHANGED '
        'FROM "Review" TO "Stopped" ON "%s" '
        'and "Story Points" IS NOT NULL'
    )

    for project in jira.projects():
        done_issues = jira.search_issues(done_issues_query % (project.key, eval_date))
        points_per_project = 0.0
        if done_issues:
            if verbose:
                print '\n* %s' % project.name.encode('utf-8')
            for issue in done_issues:
                # Story Points field is customfield_10004
                points = issue.fields().customfield_10004
                user = issue.fields().assignee.displayName
                username = issue.fields().assignee.name
                points_per_project += points

                str_line = '%s\tPuntos: %s\t%s' % (
                    issue.key,
                    points,
                    user,
                )
                if verbose:
                    print str_line.encode('utf-8')

                if user in points_per_person:
                    points_per_person[user] += issue.fields().customfield_10004
                else:
                    points_per_person[user] = issue.fields().customfield_10004
                if not user_list or username in user_list:
                    points_to_count += issue.fields().customfield_10004
            if verbose:
                print '-- Puntos pasados a Review: %s' % points_per_project
            points_at_axiacore += points_per_project

        qa_issues = jira.search_issues(qa_issues_query % (project.key, eval_date))
        qa_returned_issues = jira.search_issues(qa_returned_issues_query % (project.key, eval_date))
        if qa_issues:
            if verbose:
                print '\n* %s' % project.name.encode('utf-8')
            returned_points = sum([
                float(issue.fields().customfield_10004 or 0)
                for issue in qa_returned_issues
            ])
            qa_returned += returned_points

            total_points = sum([
                float(issue.fields().customfield_10004 or 0)
                for issue in qa_issues
            ])
            qa_total += total_points
            if verbose:
                print '-- Puntos devueltos de QA: %s de %s\t\tEfectividad: %.2f%%' % (
                    returned_points,
                    total_points,
                    100 * (1 - (0 if total_points == 0 else returned_points / total_points)),
                )

        review_issues = jira.search_issues(review_issues_query % (project.key, eval_date))
        review_returned_issues = jira.search_issues(review_returned_issues_query % (project.key, eval_date))
        if review_issues:
            if verbose:
                print '\n* %s' % project.name.encode('utf-8')
            returned_points = sum([
                float(issue.fields().customfield_10004 or 0)
                for issue in review_returned_issues
            ])
            review_returned += returned_points

            total_points = sum([
                float(issue.fields().customfield_10004 or 0)
                for issue in review_issues
            ])
            review_total += total_points
            if verbose:
                print '-- Puntos devueltos de Review: %s de %s\tEfectividad: %.2f%%' % (
                    returned_points,
                    total_points,
                    100 * (1 - (0 if total_points == 0 else returned_points / total_points)),
                )

    if simple:
        result = {
            'total_points': points_at_axiacore,
            'qa_efectivity': 100 * (1 - (qa_returned / qa_total)),
            'review_efectivity': 100 * (1 - (review_returned / review_total)),
        }
        if len(user_list):
            result['points_per_devel'] = points_to_count / (len(user_list))
        print json.dumps(result)
        return 0
    print '\n\n== Total puntos en AxiaCore:\t\t%s' % points_at_axiacore
    if len(user_list):
        print '== Total puntos / desarrollador:\t%s' % (
            points_to_count / (len(user_list))
        )
    if verbose:
        print 'Puntos totales hechos por persona (%s):' % eval_date
        for key in points_per_person.keys():
            print key.encode('utf-8'), points_per_person[key]

    if qa_total:
        print '== Total efectividad en QA:\t\t%.2f%%' % (
            100 * (1 - (qa_returned / qa_total)),
        )
    if review_total:
        print '== Total efectividad en Review:\t\t%.2f%%' % (
            100 * (1 - (review_returned / review_total)),
        )

if __name__ == '__main__':
    main()
